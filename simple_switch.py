import subprocess
import threading
import time
import json

from ryu.base import app_manager
from ryu.controller import ofp_event
from ryu.controller.handler import MAIN_DISPATCHER
from ryu.controller.handler import set_ev_cls
from ryu.ofproto import ofproto_v1_0
from ryu.lib.mac import haddr_to_bin
from ryu.lib.packet import packet
from ryu.lib.packet import ethernet
from ryu.lib.packet import ether_types


class SimpleSwitch(app_manager.RyuApp):
    OFP_VERSIONS = [ofproto_v1_0.OFP_VERSION]

    def __init__(self, *args, **kwargs):
        super(SimpleSwitch, self).__init__(*args, **kwargs)
        self.mac_to_port = {}
        self.datapaths = {}

        # Start Snort in a background thread
        self.snort_log_path = "/var/log/snort/alert.json"  
        self.snort_cmd = [
            "sudo",
            "/home/khang/Desktop/snort3/bin/snort", 
            "-i", "ens33",   
            "-c", "/home/khang/Desktop/snort3/lua/snort.lua",
            "-R", "/home/khang/Desktop/snort3/etc/snort/sample.rules",
            "-A", "json"
        ]
        threading.Thread(target=self.run_snort, daemon=True).start()
        threading.Thread(target=self.monitor_snort_alerts, daemon=True).start()

    def run_snort(self):
        self.logger.info("Starting Snort...")
        try:
            subprocess.run(self.snort_cmd)
        except Exception as e:
            self.logger.error(f"Failed to start Snort: {e}")

    def monitor_snort_alerts(self):
        self.logger.info("Monitoring Snort alerts...")
        try:
            with open(self.snort_log_path, 'r') as f:
                f.seek(0, 2)
                while True:
                    line = f.readline()
                    if not line:
                        time.sleep(1)
                        continue
                    try:
                        alert = json.loads(line)
                        src_ip = alert['_source']['src_ip']
                        self.logger.info(f"[ALERT] Blocking IP: {src_ip}")
                        self.block_ip(src_ip)
                        with open("/home/khang/Desktop/snort3/snort_blocked.log", "a") as log_file:
                            log_msg = f"{time.strftime('%Y-%m-%d %H:%M:%S')} - Blocked IP: {src_ip}\n"
                            log_file.write(log_msg)
                    except Exception as e:
                        self.logger.error(f"Error parsing alert: {e}")
        except FileNotFoundError:
            self.logger.error(f"Alert log not found at {self.snort_log_path}")

    def block_ip(self, ip):
        for dpid, dp in self.datapaths.items():
            parser = dp.ofproto_parser
            match = parser.OFPMatch(nw_src=ip, dl_type=0x0800)
            actions = []
            mod = parser.OFPFlowMod(
                datapath=dp,
                priority=100,
                match=match,
                instructions=[parser.OFPInstructionActions(dp.ofproto.OFPIT_APPLY_ACTIONS, actions)]
            )
            dp.send_msg(mod)

    def add_flow(self, datapath, in_port, dst, src, actions):
        ofproto = datapath.ofproto
        match = datapath.ofproto_parser.OFPMatch(
            in_port=in_port,
            dl_dst=haddr_to_bin(dst), dl_src=haddr_to_bin(src))
        mod = datapath.ofproto_parser.OFPFlowMod(
            datapath=datapath, match=match, cookie=0,
            command=ofproto.OFPFC_ADD, idle_timeout=0, hard_timeout=0,
            priority=ofproto.OFP_DEFAULT_PRIORITY,
            flags=ofproto.OFPFF_SEND_FLOW_REM, actions=actions)
        datapath.send_msg(mod)

    @set_ev_cls(ofp_event.EventOFPPacketIn, MAIN_DISPATCHER)
    def _packet_in_handler(self, ev):
        msg = ev.msg
        datapath = msg.datapath
        ofproto = datapath.ofproto
        parser = datapath.ofproto_parser
        pkt = packet.Packet(msg.data)
        eth = pkt.get_protocol(ethernet.ethernet)

        if eth.ethertype == ether_types.ETH_TYPE_LLDP:
            return
        dst = eth.dst
        src = eth.src
        dpid = datapath.id
        self.mac_to_port.setdefault(dpid, {})
        self.mac_to_port[dpid][src] = msg.in_port
        self.datapaths[dpid] = datapath  # Ghi nhớ datapath để sử dụng trong block_ip

        self.logger.info("packet in %s %s %s %s", dpid, src, dst, msg.in_port)

        if dst in self.mac_to_port[dpid]:
            out_port = self.mac_to_port[dpid][dst]
        else:
            out_port = ofproto.OFPP_FLOOD

        actions = [parser.OFPActionOutput(out_port)]
        if out_port != ofproto.OFPP_FLOOD:
            self.add_flow(datapath, msg.in_port, dst, src, actions)

        data = None
        if msg.buffer_id == ofproto.OFP_NO_BUFFER:
            data = msg.data
        out = parser.OFPPacketOut(
            datapath=datapath, buffer_id=msg.buffer_id, in_port=msg.in_port,
            actions=actions, data=data)
        datapath.send_msg(out)

    @set_ev_cls(ofp_event.EventOFPPortStatus, MAIN_DISPATCHER)
    def _port_status_handler(self, ev):
        msg = ev.msg
        reason = msg.reason
        port_no = msg.desc.port_no
        ofproto = msg.datapath.ofproto
        if reason == ofproto.OFPPR_ADD:
            self.logger.info("port added %s", port_no)
        elif reason == ofproto.OFPPR_DELETE:
            self.logger.info("port deleted %s", port_no)
        elif reason == ofproto.OFPPR_MODIFY:
            self.logger.info("port modified %s", port_no)
        else:
            self.logger.info("Illegal port state %s %s", port_no, reason)
