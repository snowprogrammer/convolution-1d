# 
# Synthesis run script generated by Vivado
# 

set TIME_start [clock seconds] 
proc create_report { reportName command } {
  set status "."
  append status $reportName ".fail"
  if { [file exists $status] } {
    eval file delete [glob $status]
  }
  send_msg_id runtcl-4 info "Executing : $command"
  set retval [eval catch { $command } msg]
  if { $retval != 0 } {
    set fp [open $status w]
    close $fp
    send_msg_id runtcl-5 warning "$msg"
  }
}
create_project -in_memory -part xa7a12tcpg238-2I

set_param project.singleFileAddWarning.threshold 0
set_param project.compositeFile.enableAutoGeneration 0
set_param synth.vivado.isSynthRun true
set_property webtalk.parent_dir {G:/projet labo/code_synthese/project_1/project_1.cache/wt} [current_project]
set_property parent.project_path {G:/projet labo/code_synthese/project_1/project_1.xpr} [current_project]
set_property default_lib xil_defaultlib [current_project]
set_property target_language VHDL [current_project]
set_property ip_output_repo {g:/projet labo/code_synthese/project_1/project_1.cache/ip} [current_project]
set_property ip_cache_permissions {read write} [current_project]
read_vhdl -library xil_defaultlib {
  {G:/projet labo/code_synthese/project_1/project_1.srcs/sources_1/imports/code_synthese/package_cnn.vhd}
  {G:/projet labo/code_synthese/project_1/project_1.srcs/sources_1/imports/code_synthese/ibuffer.vhd}
  {G:/projet labo/code_synthese/project_1/project_1.srcs/sources_1/imports/code_synthese/ipconv1d.vhd}
  {G:/projet labo/code_synthese/project_1/project_1.srcs/sources_1/imports/code_synthese/psum.vhd}
  {G:/projet labo/code_synthese/project_1/project_1.srcs/sources_1/imports/code_synthese/mux.vhd}
  {G:/projet labo/code_synthese/project_1/project_1.srcs/sources_1/imports/code_synthese/addition.vhd}
  {G:/projet labo/code_synthese/project_1/project_1.srcs/sources_1/imports/code_synthese/fsm.vhd}
  {G:/projet labo/code_synthese/project_1/project_1.srcs/sources_1/imports/code_synthese/1dconv_cnn.vhd}
}
# Mark all dcp files as not used in implementation to prevent them from being
# stitched into the results of this synthesis run. Any black boxes in the
# design are intentionally left as such for best results. Dcp files will be
# stitched into the design at a later time, either when this synthesis run is
# opened, or when it is stitched into a dependent implementation run.
foreach dcp [get_files -quiet -all -filter file_type=="Design\ Checkpoint"] {
  set_property used_in_implementation false $dcp
}
read_xdc {{G:/projet labo/code_synthese/project_1/project_1.srcs/constrs_1/new/temps.xdc}}
set_property used_in_implementation false [get_files {{G:/projet labo/code_synthese/project_1/project_1.srcs/constrs_1/new/temps.xdc}}]

set_param ips.enableIPCacheLiteLoad 1
close [open __synthesis_is_running__ w]

synth_design -top ldconv_cnn -part xa7a12tcpg238-2I -flatten_hierarchy none -mode out_of_context


# disable binary constraint mode for synth run checkpoints
set_param constraints.enableBinaryConstraints false
write_checkpoint -force -noxdef ldconv_cnn.dcp
create_report "synth_1_synth_report_utilization_0" "report_utilization -file ldconv_cnn_utilization_synth.rpt -pb ldconv_cnn_utilization_synth.pb"
file delete __synthesis_is_running__
close [open __synthesis_is_complete__ w]
