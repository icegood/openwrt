
#
# Copyright (C) 2006-2023 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

FW_MENU:=Firewall Extensions
NF_SUBMENU:=$(FW_MENU)/Netfilter
IPT_SUBMENU:=$(FW_MENU)/iptables
EPT_SUBMENU:=$(FW_MENU)/eptables
NFNETL_SUBMENU:=$(FW_MENU)/Netfilter netlink
NFT_SUBMENU:=$(FW_MENU)/Netfilter Table Extensions
NF_KMOD:=1
include $(INCLUDE_DIR)/netfilter.mk

define AddCommon/Netfilter
  FILES:=$(foreach mod,$(3),$(LINUX_DIR)/net/$(mod).ko)
  AUTOLOAD:=$(call AutoProbe,$(notdir $(3)))
  SUBMENU:=$(1)
#  FILE_MODULE_NAME:=$(2)
#  $(warning FILE_MODULE_NAME=$(FILE_MODULE_NAME))
endef

define AddCommon/nf
  $(call AddCommon/Netfilter,$(NF_SUBMENU),netfilter,$(1))
endef

define AddCommon/nft
  $(call AddCommon/Netfilter,$(NFT_SUBMENU),netfilter_tables,$(1))
endef

define AddCommon/nftnl
  $(call AddCommon/Netfilter,$(NFNETL_SUBMENU),netfilter_netlink,$(1))
endef

define AddCommon/ipt
  $(call AddCommon/Netfilter,$(IPT_SUBMENU),iptables,$(1))
endef

define AddCommon/eptables
  $(call AddCommon/Netfilter,$(EPT_SUBMENU),eptables,$(1))
endef

define KernelPackage/nf-reject
  TITLE:=Netfilter IPv4 reject support
  KCONFIG:= \
	CONFIG_NETFILTER=y \
	CONFIG_NETFILTER_ADVANCED=y \
	$(KCONFIG_NF_REJECT)

  $(call AddCommon/nf,$(NF_REJECT-m))
endef

$(eval $(call KernelPackage,nf-reject))


define KernelPackage/nf-reject6
  TITLE:=Netfilter IPv6 reject support
  KCONFIG:= \
	CONFIG_NETFILTER=y \
	CONFIG_NETFILTER_ADVANCED=y \
	$(KCONFIG_NF_REJECT6)
  DEPENDS:=@IPV6
  $(call AddCommon/nf,$(NF_REJECT6-m))
endef

$(eval $(call KernelPackage,nf-reject6))

define KernelPackage/nf-conncount
  TITLE:=Netfilter conncount support
  KCONFIG:=$(KCONFIG_NF_CONNCOUNT)
  HIDDEN:=1
  DEPENDS:=+kmod-nf-conntrack
  $(call AddCommon/nf,$(NF_CONNCOUNT-m))
endef

$(eval $(call KernelPackage,nf-conncount))


define KernelPackage/nf-conntrack
  TITLE:=Netfilter connection tracking
  KCONFIG:= \
	CONFIG_NETFILTER=y \
	CONFIG_NETFILTER_ADVANCED=y \
	CONFIG_NF_CONNTRACK_MARK=y \
	CONFIG_NF_CONNTRACK_ZONES=y \
	$(KCONFIG_NF_CONNTRACK)
  $(call AddCommon/nf,$(NF_CONNTRACK-m))
endef

define KernelPackage/nf-conntrack/install
	$(INSTALL_DIR) $(1)/etc/sysctl.d
	$(INSTALL_DATA) ./files/sysctl-nf-conntrack.conf $(1)/etc/sysctl.d/11-nf-conntrack.conf
endef

$(eval $(call KernelPackage,nf-conntrack))


define KernelPackage/nf-conntrack6
  TITLE:=Netfilter IPv6 connection tracking
  KCONFIG:=$(KCONFIG_NF_CONNTRACK6)
  DEPENDS:=@IPV6 +kmod-nf-conntrack
  $(call AddCommon/nf,$(NF_CONNTRACK6-m))
endef

$(eval $(call KernelPackage,nf-conntrack6))


define KernelPackage/nf-dup-inet
  TITLE:=Netfilter nf_tables dup in ip/ip6/inet family support
  HIDDEN:=1
  DEPENDS:=+kmod-nf-conntrack +IPV6:kmod-nf-conntrack6
  KCONFIG:= \
	CONFIG_NF_DUP_IPV4 \
	CONFIG_NF_DUP_IPV6

  $(call AddCommon/nf,$(P_V4)nf_dup_ipv4 $(P_V6)nf_dup_ipv6)
endef

$(eval $(call KernelPackage,nf-dup-inet))


define KernelPackage/nf-log
  TITLE:=Netfilter Logging
  KCONFIG:=$(KCONFIG_NF_LOG)
  $(call AddCommon/nf,$(NF_LOG-m))
endef

$(eval $(call KernelPackage,nf-log))


define KernelPackage/nf-log6
  TITLE:=Netfilter IPV6 Logging
  KCONFIG:=$(KCONFIG_NF_LOG6)
  DEPENDS:=@IPV6 +kmod-nf-log
  $(call AddCommon/nf,$(NF_LOG6-m))
endef

$(eval $(call KernelPackage,nf-log6))


define KernelPackage/nf-nat
  TITLE:=Netfilter NAT
  KCONFIG:=$(KCONFIG_NF_NAT)
  DEPENDS:=+kmod-nf-conntrack
  $(call AddCommon/nf,$(NF_NAT-m))
endef

$(eval $(call KernelPackage,nf-nat))


define KernelPackage/nf-nat6
  TITLE:=Netfilter IPV6-NAT
  KCONFIG:=$(KCONFIG_NF_NAT6)
  DEPENDS:=@IPV6 +kmod-nf-conntrack6 +kmod-nf-nat
  $(call AddCommon/nf,$(NF_NAT6-m))
endef

$(eval $(call KernelPackage,nf-nat6))


define KernelPackage/nf-flow
  TITLE:=Netfilter flowtable support
  KCONFIG:= \
	CONFIG_NETFILTER_INGRESS=y \
	CONFIG_NF_FLOW_TABLE \
	CONFIG_NF_FLOW_TABLE_HW
  DEPENDS:=+kmod-nf-conntrack
  $(call AddCommon/nf,$(P_XT)nf_flow_table)
endef

$(eval $(call KernelPackage,nf-flow))


define KernelPackage/nf-socket
  TITLE:=Netfilter socket lookup support
  KCONFIG:= $(KCONFIG_NF_SOCKET)
  $(call AddCommon/nf,$(NF_SOCKET-m))
endef

$(eval $(call KernelPackage,nf-socket))


define KernelPackage/nf-tproxy
  TITLE:=Netfilter tproxy support
  KCONFIG:= $(KCONFIG_NF_TPROXY)
  $(call AddCommon/nf,$(NF_TPROXY-m))
endef

$(eval $(call KernelPackage,nf-tproxy))

define KernelPackage/nf-ipt
  TITLE:=iptables => netfilter glue core
  KCONFIG:=$(KCONFIG_NF_IPT)
  $(call AddCommon/nf,$(NF_IPT-m))
endef

$(eval $(call KernelPackage,nf-ipt))


define KernelPackage/nf-ipt6
  TITLE:=Ip6tables core
  KCONFIG:=$(KCONFIG_NF_IPT6)
  DEPENDS:=+kmod-nf-ipt +kmod-nf-log6
  $(call AddCommon/nf,$(NF_IPT6-m))
endef

$(eval $(call KernelPackage,nf-ipt6))


define KernelPackage/nf-nathelper
  TITLE:=Basic Conntrack and NAT helpers
  KCONFIG:=$(KCONFIG_NF_NATHELPER)
  DEPENDS:=+kmod-nf-nat
  $(call AddCommon/nf,$(NF_NATHELPER-m))
endef

define KernelPackage/nf-nathelper/description
 Default Netfilter (IPv4) Conntrack and NAT helpers
 Includes:
 - ftp
endef

$(eval $(call KernelPackage,nf-nathelper))


define KernelPackage/nf-nathelper-extra
  TITLE:=Extra Conntrack and NAT helpers
  KCONFIG:=$(KCONFIG_NF_NATHELPER_EXTRA)
  DEPENDS:=+kmod-nf-nat +kmod-lib-textsearch +kmod-asn1-decoder
  $(call AddCommon/nf,$(NF_NATHELPER_EXTRA-m))
endef

define KernelPackage/nf-nathelper-extra/description
 Extra Netfilter (IPv4) Conntrack and NAT helpers
 Includes:
 - amanda
 - h323
 - irc
 - mms
 - pptp
 - proto_gre
 - sip
 - snmp_basic
 - tftp
 - broadcast
endef

$(eval $(call KernelPackage,nf-nathelper-extra))

define KernelPackage/ipt-core
  TITLE:=Iptables core
  KCONFIG:=$(KCONFIG_IPT_CORE)
  DEPENDS:=+kmod-nf-reject +kmod-nf-ipt +kmod-nf-log
  $(call AddCommon/ipt,$(IPT_CORE-m))
endef

define KernelPackage/br-netfilter
  TITLE:=Bridge netfilter support modules
  KCONFIG:=CONFIG_BRIDGE_NETFILTER
  DEPENDS:=+kmod-nf-conntrack
  $(call AddCommon/nf,bridge/br_netfilter)
endef

define KernelPackage/br-netfilter/install
	$(INSTALL_DIR) $(1)/etc/sysctl.d
	$(INSTALL_DATA) ./files/sysctl-br-netfilter.conf $(1)/etc/sysctl.d/11-br-netfilter.conf
endef

$(eval $(call KernelPackage,br-netfilter))


define KernelPackage/ipt-core/description
 Netfilter core kernel modules
 Includes:
 - comment
 - limit
 - LOG
 - mac
 - multiport
 - REJECT
 - TCPMSS
endef

$(eval $(call KernelPackage,ipt-core))


define AddDepends/ipt
  DEPENDS+= +kmod-ipt-core $(1)
  $(call AddCommon/ipt,$(2))
endef


define KernelPackage/ipt-conntrack
  TITLE:=Basic connection tracking modules
  KCONFIG:=$(KCONFIG_IPT_CONNTRACK)
  $(call AddDepends/ipt,+kmod-nf-conntrack,$(IPT_CONNTRACK-m))
endef

define KernelPackage/ipt-conntrack/description
 Netfilter (IPv4) kernel modules for connection tracking
 Includes:
 - conntrack
 - defrag
 - iptables_raw
 - NOTRACK
 - state
endef

$(eval $(call KernelPackage,ipt-conntrack))


define KernelPackage/ipt-conntrack-extra
  TITLE:=Extra connection tracking modules
  DEPENDS:=+kmod-nf-conncount
  KCONFIG:=$(KCONFIG_IPT_CONNTRACK_EXTRA)
  $(call AddDepends/ipt,+kmod-ipt-conntrack,$(IPT_CONNTRACK_EXTRA-m))
endef

define KernelPackage/ipt-conntrack-extra/description
 Netfilter (IPv4) extra kernel modules for connection tracking
 Includes:
 - connbytes
 - connmark/CONNMARK
 - conntrack
 - helper
 - recent
endef

$(eval $(call KernelPackage,ipt-conntrack-extra))

define KernelPackage/ipt-conntrack-label
  TITLE:=Module for handling connection tracking labels
  KCONFIG:=$(KCONFIG_IPT_CONNTRACK_LABEL)
  $(call AddDepends/ipt,+kmod-ipt-conntrack,$(IPT_CONNTRACK_LABEL-m))
endef

define KernelPackage/ipt-conntrack-label/description
 Netfilter (IPv4) module for handling connection tracking labels
 Includes:
 - connlabel
endef

$(eval $(call KernelPackage,ipt-conntrack-label))

define KernelPackage/ipt-filter
  TITLE:=Modules for packet content inspection
  KCONFIG:=$(KCONFIG_IPT_FILTER)
  $(call AddDepends/ipt,+kmod-lib-textsearch +kmod-ipt-conntrack,$(IPT_FILTER-m))
endef

define KernelPackage/ipt-filter/description
 Netfilter (IPv4) kernel modules for packet content inspection
 Includes:
 - string
 - bpf
endef

$(eval $(call KernelPackage,ipt-filter))


define KernelPackage/ipt-offload
  TITLE:=Netfilter routing/NAT offload support
  KCONFIG:=$(KCONFIG_IPT_FLOW)
  $(call AddDepends/ipt,+kmod-nf-flow,$(IPT_FLOW-m))
endef

$(eval $(call KernelPackage,ipt-offload))


define KernelPackage/ipt-ipopt
  TITLE:=Modules for matching/changing IP packet options
  KCONFIG:=$(KCONFIG_IPT_IPOPT)
  $(call AddDepends/ipt,$(IPT_IPOPT-m))
endef

define KernelPackage/ipt-ipopt/description
 Netfilter (IPv4) modules for matching/changing IP packet options
 Includes:
 - CLASSIFY
 - dscp/DSCP
 - ecn/ECN
 - hl/HL
 - length
 - mark/MARK
 - statistic
 - tcpmss
 - time
 - ttl/TTL
 - unclean
endef

$(eval $(call KernelPackage,ipt-ipopt))


define KernelPackage/ipt-ipsec
  TITLE:=Modules for matching IPSec packets
  KCONFIG:=$(KCONFIG_IPT_IPSEC)
  $(call AddDepends/ipt,$(IPT_IPSEC-m))
endef

define KernelPackage/ipt-ipsec/description
 Netfilter (IPv4) modules for matching IPSec packets
 Includes:
 - ah
 - esp
 - policy
endef

$(eval $(call KernelPackage,ipt-ipsec))

IPSET_MODULES:= \
	ipset/ip_set \
	ipset/ip_set_bitmap_ip \
	ipset/ip_set_bitmap_ipmac \
	ipset/ip_set_bitmap_port \
	ipset/ip_set_hash_ip \
	ipset/ip_set_hash_ipmac \
	ipset/ip_set_hash_ipmark \
	ipset/ip_set_hash_ipport \
	ipset/ip_set_hash_ipportip \
	ipset/ip_set_hash_ipportnet \
	ipset/ip_set_hash_mac \
	ipset/ip_set_hash_netportnet \
	ipset/ip_set_hash_net \
	ipset/ip_set_hash_netnet \
	ipset/ip_set_hash_netport \
	ipset/ip_set_hash_netiface \
	ipset/ip_set_list_set \
	xt_set

define KernelPackage/ipt-ipset
  TITLE:=IPset netfilter modules
  KCONFIG:= \
	CONFIG_IP_SET \
	CONFIG_IP_SET_MAX=256 \
	CONFIG_NETFILTER_XT_SET \
	CONFIG_IP_SET_BITMAP_IP \
	CONFIG_IP_SET_BITMAP_IPMAC \
	CONFIG_IP_SET_BITMAP_PORT \
	CONFIG_IP_SET_HASH_IP \
	CONFIG_IP_SET_HASH_IPMAC \
	CONFIG_IP_SET_HASH_IPMARK \
	CONFIG_IP_SET_HASH_IPPORT \
	CONFIG_IP_SET_HASH_IPPORTIP \
	CONFIG_IP_SET_HASH_IPPORTNET \
	CONFIG_IP_SET_HASH_MAC \
	CONFIG_IP_SET_HASH_NET \
	CONFIG_IP_SET_HASH_NETNET \
	CONFIG_IP_SET_HASH_NETIFACE \
	CONFIG_IP_SET_HASH_NETPORT \
	CONFIG_IP_SET_HASH_NETPORTNET \
	CONFIG_IP_SET_LIST_SET \
	CONFIG_NET_EMATCH_IPSET=n
  IPSET_MODULES_PARAMS:=$(foreach mod,$(IPSET_MODULES),$(P_XT)$(mod))
  $(warning IPSET_MODULES_PARAMS=$(IPSET_MODULES_PARAMS))
  $(call AddDepends/ipt,+kmod-nfnetlink,$(IPSET_MODULES_PARAMS))
endef

$(eval $(call KernelPackage,ipt-ipset))


IPVS_MODULES:= \
	ip_vs \
	ip_vs_lc \
	ip_vs_wlc \
	ip_vs_rr \
	ip_vs_wrr \
	ip_vs_lblc \
	ip_vs_lblcr \
	ip_vs_dh \
	ip_vs_sh \
	ip_vs_fo \
	ip_vs_ovf \
	ip_vs_nq \
	ip_vs_sed

define KernelPackage/nf-ipvs
  TITLE:=IP Virtual Server modules
  KCONFIG:= \
	CONFIG_IP_VS \
	CONFIG_IP_VS_IPV6=y \
	CONFIG_IP_VS_DEBUG=n \
	CONFIG_IP_VS_PROTO_TCP=y \
	CONFIG_IP_VS_PROTO_UDP=y \
	CONFIG_IP_VS_PROTO_AH_ESP=y \
	CONFIG_IP_VS_PROTO_ESP=y \
	CONFIG_IP_VS_PROTO_AH=y \
	CONFIG_IP_VS_PROTO_SCTP=y \
	CONFIG_IP_VS_TAB_BITS=12 \
	CONFIG_IP_VS_RR \
	CONFIG_IP_VS_WRR \
	CONFIG_IP_VS_LC \
	CONFIG_IP_VS_WLC \
	CONFIG_IP_VS_FO \
	CONFIG_IP_VS_OVF \
	CONFIG_IP_VS_LBLC \
	CONFIG_IP_VS_LBLCR \
	CONFIG_IP_VS_DH \
	CONFIG_IP_VS_SH \
	CONFIG_IP_VS_SED \
	CONFIG_IP_VS_NQ \
	CONFIG_IP_VS_SH_TAB_BITS=8 \
	CONFIG_IP_VS_NFCT=y \
	CONFIG_NETFILTER_XT_MATCH_IPVS
  IPVS_MODULES_PARAMS:=$(foreach mod,$(IPVS_MODULES),$(P_XT)ipvs/$(mod))
  $(call AddDepends/ipt,@IPV6 +kmod-lib-crc32c +kmod-ipt-conntrack +IPV6:kmod-nf-conntrack6,$(IPVS_MODULES_PARAMS))
endef

define KernelPackage/nf-ipvs/description
 IPVS (IP Virtual Server) implements transport-layer load balancing inside
 the Linux kernel so called Layer-4 switching.
endef

$(eval $(call KernelPackage,nf-ipvs))


define KernelPackage/nf-ipvs-ftp
  TITLE:=Virtual Server FTP protocol support
  KCONFIG:=CONFIG_IP_VS_FTP
  $(call AddDepends/ipt,kmod-nf-ipvs +kmod-nf-nat +kmod-nf-nathelper,$(P_XT)ipvs/ip_vs_ftp)
endef

define KernelPackage/nf-ipvs-ftp/description
  In the virtual server via Network Address Translation,
  the IP address and port number of real servers cannot be sent to
  clients in ftp connections directly, so FTP protocol helper is
  required for tracking the connection and mangling it back to that of
  virtual service.
endef

$(eval $(call KernelPackage,nf-ipvs-ftp))


define KernelPackage/nf-ipvs-sip
  TITLE:=Virtual Server SIP protocol support
  KCONFIG:=CONFIG_IP_VS_PE_SIP
  $(call AddDepends/ipt,kmod-nf-ipvs +kmod-nf-nathelper-extra,$(P_XT)ipvs/ip_vs_pe_sip)
endef

define KernelPackage/nf-ipvs-sip/description
  Allow persistence based on the SIP Call-ID
endef

$(eval $(call KernelPackage,nf-ipvs-sip))


define KernelPackage/ipt-nat
  TITLE:=Basic NAT targets
  KCONFIG:=$(KCONFIG_IPT_NAT)
  $(call AddDepends/ipt,+kmod-nf-nat,$(IPT_NAT-m))
endef

define KernelPackage/ipt-nat/description
 Netfilter (IPv4) kernel modules for basic NAT targets
 Includes:
 - MASQUERADE
endef

$(eval $(call KernelPackage,ipt-nat))


define KernelPackage/ipt-raw
  TITLE:=Netfilter IPv4 raw table support
  KCONFIG:=CONFIG_IP_NF_RAW
  $(call AddDepends/ipt,+kmod-iptables,$(P_V4)iptable_raw)
endef

$(eval $(call KernelPackage,ipt-raw))


define KernelPackage/ipt-raw6
  TITLE:=Netfilter IPv6 raw table support
  DEPENDS:=@IPV6
  KCONFIG:=CONFIG_IP6_NF_RAW
  $(call AddDepends/ipt,+kmod-ip6tables,$(P_V6)ip6table_raw)
endef

$(eval $(call KernelPackage,ipt-raw6))


define KernelPackage/ipt-nat6
  TITLE:=IPv6 NAT targets
  DEPENDS:=@IPV6
  KCONFIG:=$(KCONFIG_IPT_NAT6)
  $(call AddDepends/ipt,+kmod-nf-nat6 +kmod-ipt-conntrack +kmod-ipt-nat +kmod-ip6tables,$(IPT_NAT6-m))
endef

define KernelPackage/ipt-nat6/description
 Netfilter (IPv6) kernel modules for NAT targets
endef

$(eval $(call KernelPackage,ipt-nat6))


define KernelPackage/ipt-nat-extra
  TITLE:=Extra NAT targets
  KCONFIG:=$(KCONFIG_IPT_NAT_EXTRA)
  $(call AddDepends/ipt,+kmod-ipt-nat,$(IPT_NAT_EXTRA-m))
endef

define KernelPackage/ipt-nat-extra/description
 Netfilter (IPv4) kernel modules for extra NAT targets
 Includes:
 - NETMAP
 - REDIRECT
endef

$(eval $(call KernelPackage,ipt-nat-extra))

define KernelPackage/ipt-nflog
  TITLE:=Module for user-space packet logging
  KCONFIG:=$(KCONFIG_IPT_NFLOG)
  $(call AddDepends/ipt,+kmod-nfnetlink-log,$(IPT_NFLOG-m))
endef

define KernelPackage/ipt-nflog/description
 Netfilter module for user-space packet logging
 Includes:
 - NFLOG
endef

$(eval $(call KernelPackage,ipt-nflog))


define KernelPackage/ipt-nfqueue
  TITLE:=Module for user-space packet queuing
  KCONFIG:=$(KCONFIG_IPT_NFQUEUE)
  $(call AddDepends/ipt,+kmod-nfnetlink-queue,$(IPT_NFQUEUE-m))
endef

define KernelPackage/ipt-nfqueue/description
 Netfilter module for user-space packet queuing
 Includes:
 - NFQUEUE
endef

$(eval $(call KernelPackage,ipt-nfqueue))


define KernelPackage/ipt-debug
  TITLE:=Module for debugging/development
  KCONFIG:=$(KCONFIG_IPT_DEBUG)
  $(call AddDepends/ipt,+kmod-ipt-raw +IPV6:kmod-ipt-raw6,$(IPT_DEBUG-m))
endef

define KernelPackage/ipt-debug/description
 Netfilter modules for debugging/development of the firewall
 Includes:
 - TRACE
endef

$(eval $(call KernelPackage,ipt-debug))


define KernelPackage/ipt-led
  TITLE:=Module to trigger a LED with a Netfilter rule
  KCONFIG:=$(KCONFIG_IPT_LED)
  $(call AddDepends/ipt,,$(IPT_LED-m))
endef

define KernelPackage/ipt-led/description
 Netfilter target to trigger a LED when a network packet is matched.
endef

$(eval $(call KernelPackage,ipt-led))

define KernelPackage/ipt-socket
  TITLE:=Iptables socket matching support
  KCONFIG:=$(KCONFIG_IPT_SOCKET)
  $(call AddDepends/ipt,+kmod-nf-socket +kmod-nf-conntrack,$(IPT_SOCKET-m))
endef

define KernelPackage/ipt-socket/description
  Kernel modules for socket matching
endef

$(eval $(call KernelPackage,ipt-socket))

define KernelPackage/ipt-tproxy
  TITLE:=Transparent proxying support
  KCONFIG:=$(KCONFIG_IPT_TPROXY)
  $(call AddDepends/ipt,+kmod-nf-tproxy +kmod-nf-conntrack,$(IPT_TPROXY-m))
endef

define KernelPackage/ipt-tproxy/description
  Kernel modules for Transparent Proxying
endef

$(eval $(call KernelPackage,ipt-tproxy))

define KernelPackage/ipt-tee
  TITLE:=TEE support
  KCONFIG:=$(KCONFIG_IPT_TEE)
  $(call AddDepends/ipt,+kmod-ipt-conntrack +kmod-nf-dup-inet,$(IPT_TEE-m))
endef

define KernelPackage/ipt-tee/description
  Kernel modules for TEE
endef

$(eval $(call KernelPackage,ipt-tee))


define KernelPackage/ipt-u32
  TITLE:=U32 support
  KCONFIG:=$(KCONFIG_IPT_U32)
  $(call AddDepends/ipt,,$(IPT_U32-m))
endef

define KernelPackage/ipt-u32/description
  Kernel modules for U32
endef

$(eval $(call KernelPackage,ipt-u32))

define KernelPackage/ipt-checksum
  TITLE:=CHECKSUM support
  KCONFIG:=$(KCONFIG_IPT_CHECKSUM)
  $(call AddDepends/ipt,$(IPT_CHECKSUM-m))
endef

define KernelPackage/ipt-checksum/description
  Kernel modules for CHECKSUM fillin target
endef

$(eval $(call KernelPackage,ipt-checksum))


define KernelPackage/ipt-iprange
  TITLE:=Module for matching ip ranges
  KCONFIG:=$(KCONFIG_IPT_IPRANGE)
  $(call AddDepends/ipt,$(IPT_IPRANGE-m))
endef

define KernelPackage/ipt-iprange/description
 Netfilter (IPv4) module for matching ip ranges
 Includes:
 - iprange
endef

$(eval $(call KernelPackage,ipt-iprange))

define KernelPackage/ipt-cluster
  TITLE:=Module for matching cluster
  KCONFIG:=$(KCONFIG_IPT_CLUSTER)
  $(call AddDepends/ipt,+kmod-nf-conntrack,$(IPT_CLUSTER-m))
endef

define KernelPackage/ipt-cluster/description
 Netfilter (IPv4/IPv6) module for matching cluster
 This option allows you to build work-load-sharing clusters of
 network servers/stateful firewalls without having a dedicated
 load-balancing router/server/switch. Basically, this match returns
 true when the packet must be handled by this cluster node. Thus,
 all nodes see all packets and this match decides which node handles
 what packets. The work-load sharing algorithm is based on source
 address hashing.

 This module is usable for ipv4 and ipv6.

 To use it also enable iptables-mod-cluster

 see `iptables -m cluster --help` for more information.
endef

$(eval $(call KernelPackage,ipt-cluster))


define KernelPackage/ipt-extra
  TITLE:=Extra modules
  KCONFIG:=$(KCONFIG_IPT_EXTRA)
  $(call AddDepends/ipt,,$(IPT_EXTRA-m))
endef

define KernelPackage/ipt-extra/description
 Other Netfilter (IPv4) kernel modules
 Includes:
 - addrtype
 - owner
 - pkttype
 - quota
endef

$(eval $(call KernelPackage,ipt-extra))


define KernelPackage/ipt-physdev
  TITLE:=physdev module
  KCONFIG:=$(KCONFIG_IPT_PHYSDEV)
  $(call AddDepends/ipt,+kmod-br-netfilter,$(IPT_PHYSDEV-m))
endef

define KernelPackage/ipt-physdev/description
 The iptables physdev kernel module
endef

$(eval $(call KernelPackage,ipt-physdev))

define KernelPackage/ipt-hashlimit
  TITLE:=Netfilter hashlimit match
  KCONFIG:=$(KCONFIG_IPT_HASHLIMIT)
  $(call AddDepends/ipt,,$(P_XT)xt_hashlimit)
endef

define KernelPackage/ipt-hashlimit/description
 Kernel modules support for the hashlimit bucket match module
endef

$(eval $(call KernelPackage,ipt-hashlimit))

define KernelPackage/ipt-rpfilter
  TITLE:=Netfilter rpfilter match
  KCONFIG:=$(KCONFIG_IPT_RPFILTER)
  $(call AddDepends/ipt,,$(P_V4)ipt_rpfilter $(P_V6)ip6t_rpfilter)
endef

define KernelPackage/ipt-rpfilter/description
 Kernel modules support for the Netfilter rpfilter match
endef

$(eval $(call KernelPackage,ipt-rpfilter))

define KernelPackage/ip6tables
  TITLE:=IPv6 Modules
  KCONFIG:=$(KCONFIG_IPT_IPV6)
  $(call AddDepends/ipt,@IPV6 +kmod-nf-reject6 +kmod-nf-ipt6 +kmod-ipt-core,$(IPT_IPV6-m))
endef

define KernelPackage/ip6tables/description
 Netfilter IPv6 firewalling support
endef

$(eval $(call KernelPackage,ip6tables))

define KernelPackage/ip6tables-extra
  TITLE:=Extra IPv6 modules
  KCONFIG:=$(KCONFIG_IPT_IPV6_EXTRA)
  $(call AddDepends/ipt,@IPV6 +kmod-ip6tables,$(IPT_IPV6_EXTRA-m))
endef

define KernelPackage/ip6tables-extra/description
 Netfilter IPv6 extra header matching modules
endef

$(eval $(call KernelPackage,ip6tables-extra))

define KernelPackage/arptables
  SUBMENU:=$(NF_MENU)
  TITLE:=ARP firewalling modules
  ARP_MODULES := arp_tables arpt_mangle arptable_filter
  KCONFIG:=CONFIG_IP_NF_ARPTABLES \
	CONFIG_IP_NF_ARPFILTER \
	CONFIG_IP_NF_ARP_MANGLE
  PARAMS:=$(foreach mod,$(ARP_MODULES),$(P_V4)$(mod))
  $(call AddDepends/ipt,,$(PARAMS))
endef

define KernelPackage/arptables/description
 Kernel modules for ARP firewalling
endef

$(eval $(call KernelPackage,arptables))

define KernelPackage/ebtables
  TITLE:=Bridge firewalling modules
  DEPENDS:=+kmod-nf-ipt
  KCONFIG:=$(KCONFIG_EBTABLES)
  $(call AddCommon/eptables,$(EBTABLES-m))
endef

define KernelPackage/ebtables/description
  ebtables is a general, extensible frame/packet identification
  framework. It provides you to do Ethernet
  filtering/NAT/brouting on the Ethernet bridge.
endef

$(eval $(call KernelPackage,ebtables))


define AddDepends/ebtables
  SUBMENU:=$(NF_MENU)
  DEPENDS+= +kmod-ebtables $(1)
  $(call AddCommon/eptables,$(2))
endef


define KernelPackage/ebtables-ipv4
  TITLE:=ebtables: IPv4 support
  KCONFIG:=$(KCONFIG_EBTABLES_IP4)
  $(call AddDepends/ebtables,,$(EBTABLES_IP4-m))
endef

define KernelPackage/ebtables-ipv4/description
 This option adds the IPv4 support to ebtables, which allows basic
 IPv4 header field filtering, ARP filtering as well as SNAT, DNAT targets.
endef

$(eval $(call KernelPackage,ebtables-ipv4))


define KernelPackage/ebtables-ipv6
  TITLE:=ebtables: IPv6 support
  KCONFIG:=$(KCONFIG_EBTABLES_IP6)
  $(call AddDepends/ebtables,@IPV6,$(EBTABLES_IP6-m))
endef

define KernelPackage/ebtables-ipv6/description
 This option adds the IPv6 support to ebtables, which allows basic
 IPv6 header field filtering and target support.
endef

$(eval $(call KernelPackage,ebtables-ipv6))


define KernelPackage/ebtables-watchers
  TITLE:=ebtables: watchers support
  KCONFIG:=$(KCONFIG_EBTABLES_WATCHERS)
  $(call AddDepends/ebtables,,$(EBTABLES_WATCHERS-m))
endef

define KernelPackage/ebtables-watchers/description
 This option adds the log watchers, that you can use in any rule
 in any ebtables table.
endef

$(eval $(call KernelPackage,ebtables-watchers))


define KernelPackage/nfnetlink
  TITLE:=Netlink-based userspace interface
  KCONFIG:=$(KCONFIG_NFNETLINK)
  $(call AddCommon/nftnl,$(NFNETLINK-m))
endef

define KernelPackage/nfnetlink/description
 Kernel modules support for a netlink-based userspace interface
endef

$(eval $(call KernelPackage,nfnetlink))

define AddDepends/nfnetlink
  DEPENDS+=+kmod-nfnetlink $(1)
  $(call AddCommon/nftnl,$(2))
endef

define KernelPackage/nfnetlink-log
  TITLE:=Netfilter LOG over NFNETLINK interface
  KCONFIG:=$(KCONFIG_NFNETLINK_LOG)
  $(call AddDepends/nfnetlink,,$(NFNETLINK_LOG-m))
endef

define KernelPackage/nfnetlink-log/description
 Kernel modules support for logging packets via NFNETLINK
 Includes:
 - NFLOG
endef

$(eval $(call KernelPackage,nfnetlink-log))


define KernelPackage/nfnetlink-queue
  TITLE:=Netfilter QUEUE over NFNETLINK interface
  KCONFIG:=$(KCONFIG_NFNETLINK_QUEUE)
  $(call AddDepends/nfnetlink,,$(NFNETLINK_QUEUE-m))
endef

define KernelPackage/nfnetlink-queue/description
 Kernel modules support for queueing packets via NFNETLINK
 Includes:
 - NFQUEUE
endef

$(eval $(call KernelPackage,nfnetlink-queue))


define KernelPackage/nfnetlink-cthelper
  TITLE:=Netfilter User space conntrack helpers
  KCONFIG:=CONFIG_NF_CT_NETLINK_HELPER
  $(call AddDepends/nfnetlink,+kmod-nfnetlink-queue +kmod-nf-conntrack-netlink,$(P_XT)nfnetlink_cthelper)
endef

define KernelPackage/nfnetlink-cthelper/description
 Kernel modules support for a netlink-based connection tracking
 userspace helpers interface
endef

$(eval $(call KernelPackage,nfnetlink-cthelper))


define KernelPackage/nfnetlink-cttimeout
  TITLE:=Netfilter conntrack expectation timeout
  KCONFIG:=CONFIG_NF_CT_NETLINK_TIMEOUT
  $(call AddDepends/nfnetlink,+kmod-nf-conntrack @KERNEL_NF_CONNTRACK_TIMEOUT,$(P_XT)nfnetlink_cttimeout)
endef

define KernelPackage/nfnetlink-cttimeout/description
 Kernel modules support for a netlink-based connection tracking
 userspace timeout interface

 Requires CONFIG_NF_CONNTRACK_TIMEOUT (only enabled for non-small flash devices)
endef

$(eval $(call KernelPackage,nfnetlink-cttimeout))


define KernelPackage/nf-conntrack-netlink
  TITLE:=Connection tracking netlink interface
  KCONFIG:= \
	CONFIG_NF_CT_NETLINK \
	CONFIG_NF_CONNTRACK_EVENTS=y \
	CONFIG_NETFILTER_NETLINK_GLUE_CT=y 
  $(call AddDepends/nfnetlink,+kmod-nf-conntrack,$(P_XT)nf_conntrack_netlink)
endef

define KernelPackage/nf-conntrack-netlink/description
 Kernel modules support for a netlink-based connection tracking
 userspace interface
endef

$(eval $(call KernelPackage,nf-conntrack-netlink))

define KernelPackage/nft-core
  TITLE:=Netfilter nf_tables support
  DEPENDS:=+kmod-nfnetlink +kmod-nf-reject +IPV6:kmod-nf-reject6 +IPV6:kmod-nf-conntrack6 +kmod-nf-nat +kmod-nf-log +IPV6:kmod-nf-log6 +kmod-lib-crc32c
  KCONFIG:= \
	CONFIG_NFT_COMPAT=n \
	CONFIG_NFT_QUEUE=n \
	$(KCONFIG_NFT_CORE)
  $(call AddCommon/nft,$(NFT_CORE-m))
endef

define KernelPackage/nft-core/description
 Kernel module support for nftables
endef

$(eval $(call KernelPackage,nft-core))

define AddDepends/nft
  DEPENDS+=+kmod-nft-core $(1)
  $(call AddCommon/nft,$(2))
endef

define KernelPackage/nft-arp
  TITLE:=Netfilter nf_tables ARP table support
  KCONFIG:=$(KCONFIG_NFT_ARP)
  $(call AddDepends/nft,,$(NFT_ARP-m))
endef

$(eval $(call KernelPackage,nft-arp))

define KernelPackage/nft-bridge
  TITLE:=Netfilter nf_tables bridge table support
  KCONFIG:= $(KCONFIG_NFT_BRIDGE)
  $(call AddDepends/nft,,$(NFT_BRIDGE-m))
endef

$(eval $(call KernelPackage,nft-bridge))


define KernelPackage/nft-dup-inet
  TITLE:=Netfilter nf_tables dup in ip/ip6/inet family support
  KCONFIG:= CONFIG_NFT_DUP_IPV4 CONFIG_NFT_DUP_IPV6
  $(call AddDepends/nft,+kmod-nf-dup-inet,$(P_V4)nft_dup_ipv4 $(P_V6)nft_dup_ipv6)
endef

$(eval $(call KernelPackage,nft-dup-inet))


define KernelPackage/nft-nat
  TITLE:=Netfilter nf_tables NAT support
  KCONFIG:=$(KCONFIG_NFT_NAT)
  $(call AddDepends/nft,+kmod-nf-nat,$(NFT_NAT-m))
endef

$(eval $(call KernelPackage,nft-nat))


define KernelPackage/nft-offload
  TITLE:=Netfilter nf_tables routing/NAT offload support
  KCONFIG:= \
	CONFIG_NF_FLOW_TABLE_INET \
	CONFIG_NFT_FLOW_OFFLOAD
  $(call AddDepends/nft,@IPV6 +kmod-nf-flow +kmod-nft-nat,$(P_XT)nf_flow_table_inet $(P_XT)nft_flow_offload)
endef

$(eval $(call KernelPackage,nft-offload))

define KernelPackage/nft-netdev
  TITLE:=Netfilter nf_tables netdev support
  KCONFIG:= \
	CONFIG_NETFILTER_EGRESS=y \
	CONFIG_NETFILTER_INGRESS=y \
	CONFIG_NF_TABLES_NETDEV \
	CONFIG_NF_DUP_NETDEV \
	CONFIG_NFT_DUP_NETDEV \
	CONFIG_NFT_FWD_NETDEV
  $(call AddDepends/nft,@IPV6 +kmod-nf-flow +kmod-nft-nat,$(P_XT)nf_dup_netdev $(P_XT)nft_dup_netdev $(P_XT)nft_fwd_netdev)
endef

$(eval $(call KernelPackage,nft-netdev))


define KernelPackage/nft-fib
  TITLE:=Netfilter nf_tables fib support
  KCONFIG:=$(KCONFIG_NFT_FIB)
  $(call AddDepends/nft,,$(NFT_FIB-m))
endef

$(eval $(call KernelPackage,nft-fib))


define KernelPackage/nft-queue
  TITLE:=Netfilter nf_tables queue support
  KCONFIG:=$(KCONFIG_NFT_QUEUE)
  $(call AddDepends/nft,+kmod-nfnetlink-queue,$(NFT_QUEUE-m))
endef

$(eval $(call KernelPackage,nft-queue))

define KernelPackage/nft-socket
  TITLE:=Netfilter nf_tables socket support
  DEPENDS:=+kmod-nft-core
  KCONFIG:=$(KCONFIG_NFT_SOCKET)
  $(call AddDepends/nft,+kmod-nf-socket,$(NFT_SOCKET-m))
endef

$(eval $(call KernelPackage,nft-socket))

define KernelPackage/nft-tproxy
  TITLE:=Netfilter nf_tables tproxy support
  KCONFIG:=$(KCONFIG_NFT_TPROXY)
  $(call AddDepends/nft,+kmod-nf-tproxy +kmod-nf-conntrack,$(NFT_TPROXY-m))
endef

$(eval $(call KernelPackage,nft-tproxy))

define KernelPackage/nft-compat
  TITLE:=Netfilter nf_tables compat support
  KCONFIG:=$(KCONFIG_NFT_COMPAT)
  $(call AddDepends/nft,+kmod-nf-ipt,$(NFT_COMPAT-m))
endef

$(eval $(call KernelPackage,nft-compat))

define KernelPackage/nft-xfrm
  TITLE:=Netfilter nf_tables xfrm support (ipsec)
  KCONFIG:=$(KCONFIG_NFT_XFRM)
  $(call AddDepends/nft,,$(NFT_XFRM-m))
endef

$(eval $(call KernelPackage,nft-xfrm))

define KernelPackage/nft-connlimit
  TITLE:=Netfilter nf_tables connlimit support
  KCONFIG:=$(KCONFIG_NFT_CONNLIMIT)
  $(call AddDepends/nft,+kmod-nf-conncount,$(NFT_CONNLIMIT-m))
endef

$(eval $(call KernelPackage,nft-connlimit))

FILE_MODULE_NAME:=