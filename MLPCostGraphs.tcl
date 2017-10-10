#*****************************************************************************
#
#  System        : 
#  Module        : 
#  Object Name   : $RCSfile$
#  Revision      : $Revision$
#  Date          : $Date$
#  Author        : $Author$
#  Created By    : Robert Heller
#  Created       : Fri Sep 22 13:23:32 2017
#  Last Modified : <171009.2054>
#
#  Description	
#
#  Notes
#
#  History
#	
#*****************************************************************************
#
#    Copyright (C) 2017  Robert Heller D/B/A Deepwoods Software
#			51 Locke Hill Road
#			Wendell, MA 01379-9728
#
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 2 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program; if not, write to the Free Software
#    Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
#
# 
#
#*****************************************************************************


## @defgroup MLPCostGraphs MLPCostGraphs
# @brief MLPCostGraphs MLP Cost Graphing program
#
# @section SYNOPSIS SYNOPSIS
#
# MLPCostGraphs [X11 Options] [OPTIONS...]
#
# @section DESCRIPTION DESCRIPTION
#
# This program generates a pair of line graphs showing how a Broadband MLP's
# costs spread over a range of subscribers in total and subscribers per mile.
# It will illustrate how much profit or loss the MLP will incure for a given
# total monthly subscriber price for a given number of subscribers.
#
# The cost basis is computed based on the idea that there are three "buckets"
# of costs (expenses): the per network (fixed) costs, the per subscriber costs,
# and per mile costs.  The basis is computed from these numbers (presently 
# hardwired and taken from the MBI Sustainability Worksheet):
#
# @verbatim
#                            Per Network      Per Subscriber        Per Mile
#----------------------------------------------------------------------------
# MLP Administrative Costs  
# Accountant                       5,000
# Manager, Bookkeeper, 
#   Secretary, Town Treasurer      2,000
# Legal                            1,000
# Website                              0
# Marketing                            0
# Finacial Advisor                 5,000
#
# Insurance         
# Insurance Membership dues        1,200
# General Liability Insurance                                           585
# Excess Liability Insurance           0
# Public Officials Liability           0
# Property Insurance                 250
#
# Plant
# Depreciation (assume 5%/year on an
#               average per mile basis)                               1,900
#
# Utilities Telecom Council (UTC) 
#                membership
# Operations and Maintenance                           36
#
# Vendor Electronic Maintenance
# Sparing                              0
# Pole Bonding Fees (assumes about 26.74 poles/mile)                     80 
# Pole Rental Fee                                                       362
#
# Network Operator
# Fixed Fee                       25,000
# Billing/Invoicing 
#    Administration Fee 
#    (Recovering MLP
#     Cost/Subscriber)                                 36
# Other Operator/ISP fees                              
#
# Other Expenses
# POP electricity                  2,5001
# Regulatory/Inspection/Other
#-----------------------------------------------------------------------------
# Totals                          41,950               72             2,927
# @endverbatim
#
# I am going to assume a 25/month for Internet service and $20/month for 
# telephone service, on top of the MLP costs.
#
# @section OPTIONS OPTIONS
#
# If the -pdfgraphs is not specified, then the GUI is started and non of the 
# other options are checked or used.  If the -pdfgraphs option is passed, then
# two PDF files are created using the base name specified, with "-PerMile.pdf" 
# and "-PerNetwork.pdf" appended to the name.  The rest of the options are used
# to define the parameters of the graphs.  Only the -towns option is required.
#
# @arg -pdfgraphs basefile Generate PDF graph files and exit (does not start 
#                          the GUI).  Default start the GUI.
# @arg -towns townlist A list of comma separated town names.  Default none.
# @arg -goalmlpfee mlpfee  Goal MLP Fee.  Default 45.
# @arg -goalpnfract fract The fraction of the goal MLP fee that will be used 
#                         for the network wide costs (the remainder will be 
#                         used for the per-mile costs).  Default .1.
# @arg -minsub subs The minimum number of subscribers to graph, default 300.
# @arg -maxsub subs The maximum number of subscribers to graph, default 30000.
# @arg -minsubpmile subspermile The minimum number of subscribers per mile, 
#                   default 3.
# @arg -maxsubpmile subspermile The maximum number of subscribers per mile,
#                   default 20.
# 
#
# @section PARAMETERS PARAMETERS
#
# None.
#
# @section USAGE USAGE
#
# The program can be used one of two ways, either as a non-interactive CLI 
# program that generates PDF graph files or as a GUI program to generate
# the graphs on screen (and optionally produce PDF graph files).  When invoked
# with no CLI options, the GUI version is started.  Otherwise if the -pdfgraphs
# and at least the -towns options are specified (see OPTIONS above), a pair
# of PDF files are generated.
#
# The GUI program has 4 buttons along the right of the graph area.  These four
# buttons are:
#
# - Parameters This button opens the parameters section (slides out to the 
#   right). See PARAMETERS below.
# - Update This button redraws the graph, based on the parameter settings.
# - Print  This button creates PDF files from the current settings.  It will
#   ask for a base name (defaults to the names of the selected towns).
# - Quit   This button quits the program.
#
# @par
# @subsection PARAMETERS PARAMETERS
#
# The parameters section contains 44 town check buttons to select (or deselect
# towns in the network to draw a graph for).
# There is a Goal MLP fee (defaults to $45) you can set this to a value you
# fee is affordable.  This affects the blue "goal" lines.
# There is a Goal MLP Network Fraction.  This is the fraction (0 to 1.0) of 
# the goal MLP fee to be used for per network costs.  This affects the blue 
# "goal" lines.
# There are a set of four variables that can be set to adjust the range of the
# data to graph.  These values can be used to "Zoom in" or "Zoom out" the 
# graph.
# 
# @section AUTHOR AUTHOR
#
# Robert Heller \<heller\@deepsoft.com\>
#

set argv0 [file join [file dirname [info nameofexecutable]] [file rootname [file tail [info script]]]]
           
global DataDir
set DataDir [file join [file dirname [file dirname [file dirname \
                                                    [info script]]]] \
                                                    Data]


package require snit
package require pdf4tcl
package require csv
package require struct::matrix

#foreach p [package names] {
#    if {[catch {package present $p}]} {
#        puts "Available: $p [package versions $p]"
#    } else {
#        puts "Loaded: $p [package present $p]"
#    }
#}

snit::type MLPCostGraphs {
    pragma  -hastypeinfo no -hastypedestroy no -hasinstances no
    
    #** Data constants used.
    typevariable AnnualCostPerNetwork 42000;# Rounded up to an even 1000.
    typevariable AnnualCostPerSubscriber 72
    typevariable AnnualCostPerMile     3000;# Rounded up to an even 100.
    typevariable MonthlyPerSubscriberInternet 25
    typevariable MonthlyPerSubscriberPhone    20
    
    #** Town data matrix, loaded from spread sheet (CSV) file.
    typecomponent TownData -inherit yes
    #** CSV Header
    typevariable  TownData_Header
    #** Town row indexes.
    typevariable townRows -array {}
    #** Flags for town check buttons.
    typevariable townFlags -array {}
    #** The number of route miles in the network
    typevariable Miles 0
    #** The total number of subscribers in the network
    typevariable Subscribers 0
    #** The goal MLP fee.
    typevariable GoalMLPFee 45
    #** The fraction of the GoalMLPFee to be used for network wide costs.
    typevariable GoalMLPNetworkFract .1
    #****** Graph range variables
    typevariable MinSub 300;# left side of the per network graph
    typevariable MaxSub 30000;# right side of the per network graph
    typevariable MinSubPMile 3;# left side of the per mile graph
    typevariable MaxSubPMile 20;# right side of the per mile graph
    
    #*** GUI variables and components
    #** Menu
    typevariable Menu {
        "&File" {file:menu} {file} 0 {
            {command "P&rint" {file:print} "Print the current graphs (generate PDF files)" {Ctrl p} -command "[mytypemethod _Print]"}
            {command "E&xit" {file:exit} "Exit the application" {Ctrl q} -command ::exit}
        }
    }
    #** Main window
    typecomponent Main
    #** graph canvas
    typecomponent graph
    #** parameter slideout frame
    typecomponent paramslidout
    #** dialog to ask for the base name
    typecomponent askbasenameDialog
    #** base name Label Entry
    typecomponent basenameLE
    
    #** Type constructor: load town data file and initialize the matrix and 
    # the arrays used.
    typeconstructor {
        set TownData [struct::matrix]
        set tn [open [file join $::DataDir TownData.csv] r]
        set TownData_Header [::csv::split [gets $tn]]
        $TownData add columns [llength $TownData_Header]
        ::csv::read2matrix $tn $TownData
        close $tn
        set rNum 0
        foreach t [$type get column [$type getcolumnIndex Municipality]] {
            if {[string trim $t] eq {}} {continue}
            set townRows($t) $rNum
            set townFlags($t) false
            incr rNum
        }
    }
    #** Get the column index given a header pattern (glob).
    typemethod getcolumnIndex {namePattern} {
        return [lsearch -glob $TownData_Header $namePattern]
    }
    #** Compute the MonthlySubscriberFee
    typemethod MonthlySubscriberFee {miles subscribers} {
        set pernetworkmonthy \
              [expr {($AnnualCostPerNetwork / double($subscribers)) / 12.0}]
        #puts stderr "*** $type MonthlySubscriberFee: pernetworkmonthy = $pernetworkmonthy"
        set annualperscriber [expr {$AnnualCostPerSubscriber * $subscribers}]
        set totalpersubscribermonthy [expr {($annualperscriber / 12.0)}]
        #puts stderr "*** $type MonthlySubscriberFee: totalpersubscribermonthy = $totalpersubscribermonthy"
        set persubscribermonthy \
              [expr {$totalpersubscribermonthy / $subscribers}]
        #puts stderr "*** $type MonthlySubscriberFee: persubscribermonthy = $persubscribermonthy"
        set totalpermile [expr {$AnnualCostPerMile * $miles}]
        #puts stderr "*** $type MonthlySubscriberFee: totalpermile = $totalpermile"
        set totalpermilemonthy [expr {$totalpermile / 12.0}]
        #puts stderr "*** $type MonthlySubscriberFee: totalpermilemonthy = $totalpermilemonthy"
        set permilemonthly [expr {$totalpermilemonthy / double($subscribers)}]
        set mlpfee [expr {$pernetworkmonthy + $persubscribermonthy + $permilemonthly}]
        return [list $pernetworkmonthy $persubscribermonthy $permilemonthly \
                $mlpfee [expr {$mlpfee + $MonthlyPerSubscriberInternet}] \
                [expr {$mlpfee + $MonthlyPerSubscriberInternet + $MonthlyPerSubscriberPhone}]]
    }
    #** Compute the per network part of the monthly subscriber fee.
    typemethod MonthlyPerNetworkSubscriberFee {subscribers} {
        return [expr {($AnnualCostPerNetwork / double($subscribers)) / 12.0}]
    }
    #** Compute the per mile part of the monthly subscriber fee. 
    typemethod MonthlyPerMileSubscriberFee {subpermile} {
        set result [expr {($AnnualCostPerMile / double($subpermile)) / 12.0}]
        #puts stderr "*** $type MonthlyPerMileSubscriberFee: subpermile = $subpermile, result = $result"
        return $result
    }
    #** Main program.  Check CLI options and either generate PDF graph files or
    # start the GUI
    typemethod main {args} {
        #puts stderr "*** $type main $args"
        set GoalMLPFee [from args -goalmlpfee $GoalMLPFee]
        set totalannual [expr {$AnnualCostPerNetwork + ($AnnualCostPerSubscriber * $Subscribers) + ($AnnualCostPerMile * $Miles)}]
        #puts stderr "*** $type main: totalannual = $totalannual"
        set totalpermonth [expr {$totalannual / 12.0}]
        #puts stderr "*** $type main: totalpermonth = $totalpermonth"
        set totalpermonthpersub [expr {$totalpermonth / double($Subscribers)}]
        #puts stderr "*** $type main: totalpermonthpersub = $totalpermonthpersub"
        set basefile [from args -pdfgraphs {}]
        if {$basefile eq {}} {
            $type StartGUI
        } else {
            eval [list $type PDFGraphs $basefile \
                  -goalmlpfee $GoalMLPFee] $args
        }
    }
    #** Function bound to the command for the fraction scale widget
    typemethod _updateGoalMLPNetworkFract {newfract} {
        $paramslidout.goalmlpnetfractlf configure \
              -text [format "Goal MLP Network Fraction (%g)" $newfract]
    }
    #** Function bound to the town check buttons.
    typemethod _UpdateMilesSubscribers {town} {
        set row $townRows($town)
        set tMiles [$type get cell [$type getcolumnIndex "*Route Miles*"] $row]
        set tSubs  [$type get cell [$type getcolumnIndex "Updated Town  Premise*"] $row]
        if {$townFlags($town)} {
            set Miles [expr {$Miles + $tMiles}]
            set Subscribers [expr {$Subscribers + $tSubs}]
        } else {
            set Miles [expr {$Miles - $tMiles}]
            set Subscribers [expr {$Subscribers - $tSubs}]
        }
    }
    #** Build and start the GUI
    typemethod StartGUI {} {
        package require Tk
        package require tile
        
        package require MainWindow
        package require snitStdMenuBar
        package require LabelFrames
        package require Dialog
        
        set Main [mainwindow .main -menu [subst $Menu]]
        pack $Main -expand yes -fill both
        set frame [$Main scrollwindow getframe]
        set graph [canvas $frame.graph]
        $Main scrollwindow setwidget $graph
        $graph configure -scrollregion {0 0 600 1200}
        $Main buttons add ttk::button parameters -text "Parameters" -command [mytypemethod _Parameters]
        $Main buttons add ttk::button update -text "Update" -command [mytypemethod _Update]
        $Main buttons add ttk::button print -text "Print" -command [mytypemethod _Print]
        $Main buttons add ttk::button quit -text "Quit" -command ::exit
        set paramslidout [$Main slideout add Parameters]
        LabelEntry $paramslidout.miles -label "Total Miles: " \
              -editable no -textvariable [mytypevar Miles]
        pack $paramslidout.miles -expand yes -fill x
        LabelEntry $paramslidout.subscribers -label "Total Subscribers: " \
              -editable no -textvariable [mytypevar Subscribers]
        pack $paramslidout.subscribers -expand yes -fill x
        ttk::labelframe $paramslidout.selecttowns \
              -text "Select Towns"
        pack $paramslidout.selecttowns -expand yes -fill x
        set rNum 0
        set gr 0
        set gc 0
        foreach t [lsort -dictionary [array names townRows]] {
            set w [string tolower [regsub -all { } $t {}]]
            set nameList [list]
            foreach n [split $t { }] {
                lappend nameList [string totitle $n]
            }
            set name [join $nameList { }]
            ttk::checkbutton $paramslidout.selecttowns.$w -text "$name" \
                  -offvalue false -onvalue true \
                  -variable [mytypevar townFlags($t)] \
                  -command [mytypemethod _UpdateMilesSubscribers $t]
            grid $paramslidout.selecttowns.$w -column $gc -row $gr -sticky news
            incr gc
            if {$gc == 4} {
                incr gr
                set gc 0
            }
        }
        grid columnconfigure $paramslidout.selecttowns 0 -weight 1 -uniform 0
        grid columnconfigure $paramslidout.selecttowns 1 -weight 1 -uniform 1
        grid columnconfigure $paramslidout.selecttowns 2 -weight 1 -uniform 2
        grid columnconfigure $paramslidout.selecttowns 3 -weight 1 -uniform 3
        LabelSpinBox $paramslidout.goalmlpfee -label "Goal MLP Fee: " \
              -range {10 100 1} \
              -textvariable [mytypevar GoalMLPFee]
        pack $paramslidout.goalmlpfee -expand yes -fill x
        ttk::labelframe $paramslidout.goalmlpnetfractlf \
              -text [format "Goal MLP Network Fraction (%g)" \
                     $GoalMLPNetworkFract]
        pack $paramslidout.goalmlpnetfractlf -expand yes -fill x
        ttk::scale $paramslidout.goalmlpnetfractlf.fract -orient horizontal \
              -from .01 -to .99 -variable [mytypevar GoalMLPNetworkFract] \
              -command [mytypemethod _updateGoalMLPNetworkFract]
        pack $paramslidout.goalmlpnetfractlf.fract -expand yes -fill x
        LabelSpinBox $paramslidout.minsub -label "Minimum Subscribers: " \
              -range {10 30000 10} \
              -textvariable [mytypevar MinSub]
        pack $paramslidout.minsub -expand yes -fill x
        LabelSpinBox $paramslidout.maxsub -label "Maximum Subscribers: " \
              -range {10 30000 10} \
              -textvariable [mytypevar MaxSub]
        pack $paramslidout.maxsub -expand yes -fill x
        LabelSpinBox $paramslidout.minsubpmile -label "Minimum Subscribers/Mile: " \
              -range {1 30 1} \
              -textvariable [mytypevar MinSubPMile]
        pack $paramslidout.minsubpmile -expand yes -fill x
        LabelSpinBox $paramslidout.maxsubpmile -label "Maximum Subscribers/Mile: " \
              -range {1 30 1} \
              -textvariable [mytypevar MaxSubPMile]
        pack $paramslidout.maxsubpmile -expand yes -fill x
        ttk::button $paramslidout.close -text "Close" \
              -command [mytypemethod _CloseParams]
        pack $paramslidout.close -expand yes -fill x
        set askbasenameDialog [Dialog .askbasenameDialog \
                               -modal local \
                               -bitmap questhead \
                               -parent . \
                               -transient yes \
                               -title "Enter the base file name:" \
                               -cancel 1 -default 0]
        $askbasenameDialog add print  -text {Print} \
              -command [mytypemethod _basenameDialogPrint]
        $askbasenameDialog add cancel -text {Cancel} \
              -command [mytypemethod _basenameDialogCancel]
        set frame [$askbasenameDialog getframe]
        set basenameLE [LabelEntry $frame.basenameLE -label "Basename: "]
        pack $basenameLE -fill x -expand yes
        $Main showit
    }
    #** Function bound to the Print button on the askbasenameDialog.
    typemethod _basenameDialogPrint {} {
        set answer [$basenameLE cget -text]
        $askbasenameDialog enddialog $answer
    }
    #** Function bound to the Cancel button on the askbasenameDialog.
    typemethod _basenameDialogCancel {} {
        $askbasenameDialog enddialog {}
    }
    #** Function bound to the Parameters button on the main window
    typemethod _Parameters {} {
        $Main slideout show Parameters
    }
    #** Function bound to the Close button on the Parameters slideout
    typemethod _CloseParams {} {
        $Main slideout hide Parameters
    }
    #** Function bound to the Update button on the main window
    # This function update (recomputes and redraws the graphs).
    typemethod _Update {} {
        # Compute MLP fee values
        set goalpnmlpfee [expr {$GoalMLPFee * $GoalMLPNetworkFract}]
        set goalpmmlpfee [expr {$GoalMLPFee * (1.0-$GoalMLPNetworkFract)}]
        # Compute Y scales
        set minPNdollars [$type MonthlyPerNetworkSubscriberFee $MaxSub]
        set maxPNdollars [$type MonthlyPerNetworkSubscriberFee $MinSub]
        set minPMdollars [$type MonthlyPerMileSubscriberFee $MaxSubPMile]
        set maxPMdollars [$type MonthlyPerMileSubscriberFee $MinSubPMile]
        # clear off old graph
        $graph delete all
        #** Draw Per Network graph
        # Draw scales
        set scaleX [canvas_drawXaxis $graph [expr {.5 * 72}] [expr {6 * 72}] [expr {.5 * 72}] [expr {.125 * 72}] $MinSub $MaxSub {Total Subscribers}]
        set scaleY [canvas_drawYaxis $graph [expr {.5 * 72}] [expr {6 * 72}] [expr {.5 * 72}] [expr {.125 * 72}] $maxPNdollars $minPNdollars {MLP Fee}]
        # Draw graph
        $type canvas_drawLineGraph $graph [expr {.5 * 72}] $scaleX [expr {.5 * 72}] $scaleY $MinSub $MaxSub $minPNdollars [mytypemethod MonthlyPerNetworkSubscriberFee]
        # Draw blue (goal) and red (actual) lines
        set YGoal [expr {(($goalpnmlpfee-$minPNdollars)*$scaleY)+(.5 * 72)}]
        $graph create line [expr {.5 * 72}] -$YGoal [expr {6 * 72}] -$YGoal -fill blue
        set XSubs [expr {(($Subscribers-$MinSub)*$scaleX)+(.5 * 72)}]
        $graph create line $XSubs [expr {-.5 * 72}] $XSubs [expr {-6 * 72}] -fill red
        # Draw legend
        $type canvas_Legend $graph [expr {.75 * 72}] [expr {5.5 * 72}] "Per Network Costs vs.\ntotal Subscribers" $goalpnmlpfee "Goal per-network MLP Fee" $Subscribers "Total Subscribers"
        #** Draw Per Mile graph
        # Draw scales
        set scaleX [canvas_drawXaxis $graph [expr {.5 * 72}] [expr {6 * 72}] [expr {7 * 72}] [expr {.125 * 72}] $MinSubPMile $MaxSubPMile {Subscribers per Mile}]
        set scaleY [canvas_drawYaxis $graph [expr {7 * 72}] [expr {12.5 * 72}] [expr {.5 * 72}] [expr {.125 * 72}] $maxPMdollars $minPMdollars {MLP Fee}]
        # Draw graph
        $type canvas_drawLineGraph $graph [expr {.5 * 72}] $scaleX [expr {7 * 72}] $scaleY $MinSubPMile $MaxSubPMile  $minPMdollars [mytypemethod MonthlyPerMileSubscriberFee]
        # Draw blue (goal) and red (actual) lines
        set YGoal [expr {(($goalpmmlpfee-$minPMdollars)*$scaleY)+(7 * 72)}]
        $graph create line [expr {.5 * 72}] -$YGoal [expr {6 * 72}] -$YGoal -fill blue
        set XSubsMile [expr {((($Subscribers/double($Miles))-$MinSubPMile)*$scaleX)+(.5 * 72)}]
        $graph create line $XSubsMile [expr {-7 * 72}] $XSubsMile [expr {-12.5 * 72}] -fill red
        # Draw legend
        $type canvas_Legend $graph [expr {.75 * 72}] [expr {12 * 72}] "Per Mile Costs vs.\nSubscribers per Mile" $goalpmmlpfee "Goal per-mile MLP Fee" [expr {$Subscribers / double($Miles)}] "Subscribers per mile"
        # Define scroll region
        $graph configure -scrollregion [$graph bbox all]
    }
    #** Function bound to Print button / menu item
    # Calls PDFGraphs function to create the PDF files.
    typemethod _Print {} {
        set towns [list]
        foreach t [lsort -dictionary [array names townRows]] {
            if {$townFlags($t)} {
                lappend towns $t
            }
        }
        if {[llength $towns] == 0} {
            tk_messageBox -type ok -icon error -message "No towns selected!"
            return
        }
        $basenameLE configure -text [regsub -all { } [join $towns "-"] {_}]
        set basename [$askbasenameDialog draw]
        if {$basename eq {}} {return}
        $type PDFGraphs $basename -towns [join $towns ","] \
              -goalmlpfee $GoalMLPFee \
              -goalpnfract $GoalMLPNetworkFract \
              -minsub $MinSub \
              -maxsub $MaxSub \
              -minsubpmile $MinSubPMile \
              -maxsubpmile $MaxSubPMile
        tk_messageBox -type ok -icon info \
              -message [format "Wrote %s-PerNetwork.pdf and %s-PerMile.pdf" \
                        $basename $basename]
    }
    #** PDF Graph function
    typemethod PDFGraphs {basefile args} {
        set towns [from args -towns {}]
        if {$towns eq {}} {
            if {[catch {package present Tk]} {
                    error "No towns selected!"
                    exit 99
                } else {
                    tk_messageBox -type ok -icon error -message "No towns selected!"
                    return
                }
            }
        }
        set Miles 0
        set Subscribers 0
        foreach T [split $towns ","] {
            set t [string toupper $T]
            if {[info exists townRows($t)]} {
                set row $townRows($t)
                set tMiles [$type get cell [$type getcolumnIndex "*Route Miles*"] $row]
                set tSubs  [$type get cell [$type getcolumnIndex "Updated Town  Premise*"] $row]
                set Miles [expr {$Miles + $tMiles}]
                set Subscribers [expr {$Subscribers + $tSubs}]
            }
        }
        # Compute MLP fee values
        set goalmlpfee [from args -goalmlpfee $GoalMLPFee]
        set goalpnfract [from args -goalpnfract $GoalMLPNetworkFract]
        set goalpnmlpfee [expr {$goalmlpfee * $goalpnfract}]
        set goalpmmlpfee [expr {$goalmlpfee * (1.0-$goalpnfract)}]
        # Compute Y scales
        set minsub [from args -minsub $MinSub]
        set maxsub [from args -maxsub $MaxSub]
        set minsubpmile [from args -minsubpmile $MinSubPMile]
        set maxsubpmile [from args -maxsubpmile $MaxSubPMile]
        set minPNdollars [$type MonthlyPerNetworkSubscriberFee $maxsub]
        set maxPNdollars [$type MonthlyPerNetworkSubscriberFee $minsub]
        set minPMdollars [$type MonthlyPerMileSubscriberFee $maxsubpmile]
        set maxPMdollars [$type MonthlyPerMileSubscriberFee $minsubpmile]
        #** Draw Per Network graph
        # Create fresh PDF file
        set pdfgraph [::pdf4tcl::new %AUTO% -file "${basefile}-PerNetwork.pdf" \
                     -paper [list [expr {6 * 72}] [expr {6 * 72}]] \
                     -unit p]
        $pdfgraph startPage -paper [list [expr {6 * 72}] [expr {6 * 72}]] \
              -orient false
        # Draw scales
        set scaleX [pdf_drawXaxis $pdfgraph [expr {.5 * 72}] [expr {6 * 72}] [expr {.5 * 72}] [expr {.125 * 72}] $minsub $maxsub {Total SubScribers}]
        set scaleY [pdf_drawYaxis $pdfgraph [expr {.5 * 72}] [expr {6 * 72}] [expr {.5 * 72}] [expr {.125 * 72}] $maxPNdollars $minPNdollars {MLP Fee}]
        # Draw graph
        $type pdf_drawLineGraph $pdfgraph [expr {.5 * 72}] $scaleX [expr {.5 * 72}] $scaleY $minsub $maxsub $minPNdollars [mytypemethod MonthlyPerNetworkSubscriberFee]
        # Draw blue (goal) and red (actual) lines
        set YGoal [expr {(($goalpnmlpfee-$minPNdollars)*$scaleY)+(.5 * 72)}]
        $pdfgraph setStrokeColor 0 0 1.0
        $pdfgraph line [expr {.5 * 72}] $YGoal [expr {6 * 72}] $YGoal
        $pdfgraph setStrokeColor 1.0 0 0
        set XSubs [expr {(($Subscribers-$minsub)*$scaleX)+(.5 * 72)}]
        $pdfgraph line $XSubs [expr {.5 * 72}] $XSubs [expr {6 * 72}]
        # Draw legend
        $type pdf_Legend $pdfgraph [expr {.75 * 72}] [expr {5.5 * 72}] "Per Network Costs vs.\ntotal Subscribers" $goalpnmlpfee "Goal per-network MLP Fee" $Subscribers "Total Subscribers"
        # Close PDF file
        $pdfgraph destroy
        #** Draw Per Mile graph
        # Create new PDF file
        set pdfgraph [::pdf4tcl::new %AUTO% -file "${basefile}-PerMile.pdf" \
                     -paper [list [expr {6 * 72}] [expr {6 * 72}]] \
                     -unit p]
        $pdfgraph startPage -paper [list [expr {6 * 72}] [expr {6 * 72}]] \
              -orient false
        # Draw scales
        set scaleX [pdf_drawXaxis $pdfgraph [expr {.5 * 72}] [expr {6 * 72}] [expr {.5 * 72}] [expr {.125 * 72}] $minsubpmile $maxsubpmile {Subscribers Per Mile}]
        set scaleY [pdf_drawYaxis $pdfgraph [expr {.5 * 72}] [expr {6 * 72}] [expr {.5 * 72}] [expr {.125 * 72}] $maxPMdollars $minPMdollars {MLP Fee}]
        # Draw graph
        $type pdf_drawLineGraph $pdfgraph [expr {.5 * 72}] $scaleX [expr {.5 * 72}] $scaleY $minsubpmile $maxsubpmile $minPMdollars [mytypemethod MonthlyPerMileSubscriberFee]
        # Draw blue (goal) and red (actual) lines
        set YGoal [expr {(($goalpmmlpfee-$minPMdollars)*$scaleY)+(.5 * 72)}]
        $pdfgraph setStrokeColor 0 0 1.0
        $pdfgraph line [expr {.5 * 72}] $YGoal [expr {6 * 72}] $YGoal
        $pdfgraph setStrokeColor 1.0 0 0
        #puts stderr "*** $type PDFGraphs: subs/mile is [expr {(($Subscribers/double($Miles)))}]"
        set XSubsMile [expr {((($Subscribers/double($Miles))-$minsubpmile)*$scaleX)+(.5 * 72)}]
        $pdfgraph line $XSubsMile [expr {.5 * 72}] $XSubsMile [expr {6 * 72}]
        # Draw legend
        $type pdf_Legend $pdfgraph [expr {.75 * 72}] [expr {5.5 * 72}] "Per Mile Costs vs.\nSubscribers per Mile" $goalpmmlpfee "Goal per-mile MLP Fee" [expr {$Subscribers / double($Miles)}] "Subscribers per mile"
        # Close file
        $pdfgraph destroy
    }
    #** Draw PDF Line graph
    typemethod pdf_drawLineGraph {pdf minX scaleX minY scaleY left right bottom funct} {
        set drange [expr {$right - $left}]
        set delta  [expr {$drange / 25.0}]
        #puts stderr "*** $type pdf_drawLineGraph: drange = $drange, delta = $delta"
        for {set P $left} {$P < $right} {set P [expr {$P + $delta}]} {
            #puts stderr "*** $type pdf_drawLineGraph: P = $P"
            set X [expr {($P * $scaleX)+$minX}]
            set PP [uplevel #0 "$funct $P"]
            set Y [expr {(($PP-$bottom) * $scaleY)+$minY}]
            if {$P != $left} {$pdf line $lastX $lastY $X $Y}
            set lastX $X
            set lastY $Y
        }
    }
     #** Draw X Axis to PDF file
    proc pdf_drawXaxis {pdf minX maxX Y tick left right legend} {
        set drange [expr {$right - $left}]
        set prange [expr {$maxX - $minX}]
        set delta  [expr {$drange / 25.0}]
        set scaleX [expr {$prange / $drange}]
        #puts stderr "*** pdf_drawXaxis: drange = $drange, prange = $prange, delta = $delta, scaleX = $scaleX"
        $pdf setLineStyle 2.0
        $pdf line $minX $Y $maxX $Y
        set l 0
        for {set P $left} {$P < $right} {set P [expr {$P + $delta}]} {
            set X [expr {(($P - $left) * $scaleX)+$minX}]
            $pdf line $X $Y $X [expr {$Y - $tick}]
            $pdf setFont .125i Courier
            if {($l % 10) == 0} {
                set lab [string trim [format "%5g" $P]]
                set labw [$pdf getStringWidth $lab]
                set offset [expr {$labw / 2.0}]
                $pdf text $lab -x [expr {$X - $offset}] -y [expr {$Y - ($tick*2)}]
            }
            incr l
        }
        $pdf text $legend -x [expr {($prange / 2)+$minX}] -y 0
        return $scaleX
    }
    # Draw Y Axis to PDF file
    proc pdf_drawYaxis {pdf minY maxY X tick bottom top legend} {
        set drange [expr {$bottom - $top}]
        set prange [expr {$maxY - $minY}]
        set delta  [expr {$drange / 25.0}]
        set scaleY [expr {$prange / $drange}]
        #puts stderr "*** pdf_drawYaxis: drange = $drange, prange = $prange, delta = $delta, scaleY = $scaleY"
        $pdf setLineStyle 2.0
        $pdf line $X $minY $X $maxY
        set l 0
        for {set P $top} {$P < $bottom} {set P [expr {$P + $delta}]} {
            set Y  [expr {(($P-$top) * $scaleY)+$minY}]
            #puts stderr "*** pdf_drawYaxis: Y = $Y"
            $pdf line $X $Y [expr {$X - $tick}] $Y
            $pdf setFont .125i Courier
            if {($l % 10) == 0} {
                set lab [string trim [format {$%5.2f} $P]]
                set labw [$pdf getStringWidth $lab]
                set offset [expr {$labw / 2.0}]
                $pdf text $lab -x [expr {$X  - ($tick*2.0)}]  -y [expr {$Y + $offset}] -angle 90
            }
            incr l
        }
        $pdf text $legend -x 0 -y [expr {($prange / 2.0)+$minY}] -angle 90
        return $scaleY
    }
    #** Draw PDF Legend
    typemethod pdf_Legend {pdf legendX legendY title bluevalue bluetitle redvalue redtitle} {
        $pdf setFont .125i Courier-Bold
        $pdf setFillColor 0 0 0
        $pdf text "$title" -x $legendX -y $legendY
        set legendY [expr {$legendY - (.260*72)}]
        $pdf setFillColor 0 0 1
        $pdf text [format {%s ($%5.2f)} $bluetitle $bluevalue] \
              -x $legendX -y $legendY
        set legendY [expr {$legendY - (.130*72)}]
        $pdf setFillColor 1 0 0
        $pdf text [format {%s (%g)} $redtitle $redvalue] \
              -x $legendX -y $legendY
    }
    #** Draw Line graph on screen
    typemethod canvas_drawLineGraph {canvas minX scaleX minY scaleY left right bottom funct} {
        set drange [expr {$right - $left}]
        set delta  [expr {$drange / 25.0}]
        #puts stderr "*** $type canvas_drawLineGraph: drange = $drange, delta = $delta"
        for {set P $left} {$P < $right} {set P [expr {$P + $delta}]} {
            #puts stderr "*** $type canvas_drawLineGraph: P = $P"
            set X [expr {(($P-$left) * $scaleX)+$minX}]
            set PP [uplevel #0 "$funct $P"]
            set Y [expr {(($PP-$bottom) * $scaleY)+$minY}]
            if {$P != $left} {$canvas create line $lastX -$lastY $X -$Y}
            set lastX $X
            set lastY $Y
        }
    }
    #** Helper function to get string width in pixels
    proc canvas_StringWidth {c text font} {
        set i [$c create text 0 0 -text $text -font $font]
        lassign [$c bbox $i] x1 y1 x2 y2
        $c delete $i
        return [expr {$x2 - $x1}]
    }
    #** Helper function to get string height in pixels
    proc canvas_StringHeight {c text font} {
        set i [$c create text 0 0 -text $text -font $font]
        lassign [$c bbox $i] x1 y1 x2 y2
        $c delete $i
        return [expr {abs($y2 - $y1)}]
    }
    #** Draw X Axis on screen
    proc canvas_drawXaxis {canvas minX maxX Y tick left right legend} {
        set drange [expr {$right - $left}]
        set prange [expr {$maxX - $minX}]
        set delta  [expr {$drange / 25.0}]
        set scaleX [expr {$prange / $drange}]
        #puts stderr "*** canvas_drawXaxis: drange = $drange, prange = $prange, delta = $delta, scaleX = $scaleX"
        $canvas create line $minX -$Y $maxX -$Y
        set l 0
        set font [font create -family Courier -size -18]
        for {set P $left} {$P < $right} {set P [expr {$P + $delta}]} {
            set X [expr {(($P-$left) * $scaleX)+$minX}]
            $canvas create line $X -$Y $X [expr {-$Y + $tick}]
            if {($l % 10) == 0} {
                set lab [string trim [format "%5g" $P]]
                set labw [canvas_StringWidth $canvas $lab $font]
                set offset [expr {$labw / 2.0}]
                $canvas create text [expr {$X - $offset}] [expr {-$Y + $tick}] -text $lab -font $font -anchor n
            }
            incr l
        }
        $canvas create text [expr {($prange / 2)+$minX}] [expr {-$Y + ($tick*3)}] -text $legend -font $font -anchor n
        return $scaleX
    }
    #** Draw Y Axis on screen
    proc canvas_drawYaxis {canvas minY maxY X tick bottom top legend} {
        set drange [expr {$bottom - $top}]
        set prange [expr {$maxY - $minY}]
        set delta  [expr {$drange / 25.0}]
        set scaleY [expr {$prange / $drange}]
        #puts stderr "*** canvas_drawYaxis: drange = $drange, prange = $prange, delta = $delta, scaleY = $scaleY"
        $canvas create line $X -$minY $X -$maxY
        set l 0
        set font [font create -family Courier -size -18]
        for {set P $top} {$P < $bottom} {set P [expr {$P + $delta}]} {
            set Y  [expr {(($P-$top) * $scaleY)+$minY}]
            #puts stderr "*** canvas_drawYaxis: Y = $Y"
            $canvas create line $X -$Y [expr {$X - $tick}] -$Y
            if {($l % 10) == 0} {
                set lab [string trim [format {$%5.2f} $P]]
                set labw [canvas_StringWidth  $canvas $lab $font]
                $canvas create text [expr {$X - $tick}] -$Y -text $lab -font $font -anchor e
            }
            incr l
        }
        $canvas create text 0 [expr {-(($prange / 2.0)+$minY)}] -text $legend -font $font -anchor e
        return $scaleY
    }
    #** Draw Legend on screen
    typemethod canvas_Legend {canvas legendX legendY title bluevalue bluetitle redvalue redtitle} {
        set font [font create -family Courier -size -18 -weight bold]
        $canvas create text $legendX -$legendY -font $font -fill black \
              -text "$title" -anchor nw
        set legendY [expr {$legendY - 40}]
        $canvas create text $legendX -$legendY -font $font -fill blue \
              -text [format {%s ($%5.2f)} $bluetitle $bluevalue] -anchor nw
        set legendY [expr {$legendY - 20}]
        $canvas create text $legendX -$legendY -font $font -fill red \
              -text [format {%s (%g)} $redtitle $redvalue] -anchor nw
    }
}

#** Call main function with the CLI arguments.

global argv

eval [list MLPCostGraphs main] $::argv
