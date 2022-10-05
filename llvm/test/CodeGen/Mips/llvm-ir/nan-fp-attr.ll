; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -march=mips -mcpu=mips32 | FileCheck %s --check-prefix=MIPS32R1
; RUN: llc < %s -march=mips -mcpu=mips32r2 | FileCheck %s --check-prefix=MIPS32R2
; RUN: llc < %s -march=mips -mcpu=mips32r2 -mattr=+abs2008 | FileCheck %s --check-prefix=MIPS32R2-ABS2K8
; RUN: llc < %s -march=mips -mcpu=mips32r2 -mattr=+abs2008,+fp64 | FileCheck %s --check-prefix=MIPS32R2-ABS2K8
; RUN: llc < %s -march=mips -mcpu=mips32r2 -mattr=+fp64 | FileCheck %s --check-prefix=MIPS32R2
; RUN: llc < %s -march=mips -mcpu=mips32r6 | FileCheck %s --check-prefix=MIPS32R6
; RUN: llc < %s -march=mips64 -mcpu=mips64 | FileCheck %s --check-prefix=MIPS64R1
; RUN: llc < %s -march=mips64 -mcpu=mips64r2 | FileCheck %s --check-prefix=MIPS64R2
; RUN: llc < %s -march=mips64 -mcpu=mips64r2 -mattr=+abs2008 | FileCheck %s --check-prefix=MIPS64R2-ABS2K8
; RUN: llc < %s -march=mips64 -mcpu=mips64r6 | FileCheck %s --check-prefix=MIPS64R6
; RUN: llc < %s -march=mips64 -mcpu=mips64r6 -mattr=+abs2008 | FileCheck %s --check-prefix=MIPS64R6-ABS2K8
; RUN: llc < %s -march=mips -mcpu=mips32r2 -mattr=+micromips | FileCheck %s --check-prefix=MM
; RUN: llc < %s -march=mips -mcpu=mips32r2 -mattr=+micromips,+abs2008 | FileCheck %s --check-prefix=MM-ABS2K8
; RUN: llc < %s -march=mips -mcpu=mips32r2 -mattr=+micromips,+abs2008,+fp64 | FileCheck %s --check-prefix=MM-ABS2K8
; RUN: llc < %s -march=mips -mcpu=mips32r2 -mattr=+micromips,+fp64 | FileCheck %s --check-prefix=MM
; RUN: llc < %s -march=mips -mcpu=mips32r6 -mattr=+micromips | FileCheck %s --check-prefix=MMR6

; Test that the instruction selection for the case of `abs.s` and `abs.d`
; matches the expected behaviour. In the default case with NaNs and no "abs2008"
; mode MIPS treats abs.s and abs.d as arithmetic fp instructions triggering
; a fp exception on execution if the input is a NaN. This results in no abs.[sd]
; instructions.

; In the case where no NaNs are present is asserted or in "abs2008" mode,
; abs.[sd] instructions are selected.

declare double @llvm.fabs.f64(double)
declare float @llvm.fabs.f32(float)

define dso_local double @foo(double %a) #0 {
; MIPS32R1-LABEL: foo:
; MIPS32R1:       # %bb.0: # %entry
; MIPS32R1-NEXT:    jr $ra
; MIPS32R1-NEXT:    abs.d $f0, $f12
;
; MIPS32R2-LABEL: foo:
; MIPS32R2:       # %bb.0: # %entry
; MIPS32R2-NEXT:    jr $ra
; MIPS32R2-NEXT:    abs.d $f0, $f12
;
; MIPS32R2-ABS2K8-LABEL: foo:
; MIPS32R2-ABS2K8:       # %bb.0: # %entry
; MIPS32R2-ABS2K8-NEXT:    jr $ra
; MIPS32R2-ABS2K8-NEXT:    abs.d $f0, $f12
;
; MIPS32R6-LABEL: foo:
; MIPS32R6:       # %bb.0: # %entry
; MIPS32R6-NEXT:    jr $ra
; MIPS32R6-NEXT:    abs.d $f0, $f12
;
; MIPS64R1-LABEL: foo:
; MIPS64R1:       # %bb.0: # %entry
; MIPS64R1-NEXT:    jr $ra
; MIPS64R1-NEXT:    abs.d $f0, $f12
;
; MIPS64R2-LABEL: foo:
; MIPS64R2:       # %bb.0: # %entry
; MIPS64R2-NEXT:    jr $ra
; MIPS64R2-NEXT:    abs.d $f0, $f12
;
; MIPS64R2-ABS2K8-LABEL: foo:
; MIPS64R2-ABS2K8:       # %bb.0: # %entry
; MIPS64R2-ABS2K8-NEXT:    jr $ra
; MIPS64R2-ABS2K8-NEXT:    abs.d $f0, $f12
;
; MIPS64R6-LABEL: foo:
; MIPS64R6:       # %bb.0: # %entry
; MIPS64R6-NEXT:    jr $ra
; MIPS64R6-NEXT:    abs.d $f0, $f12
;
; MIPS64R6-ABS2K8-LABEL: foo:
; MIPS64R6-ABS2K8:       # %bb.0: # %entry
; MIPS64R6-ABS2K8-NEXT:    jr $ra
; MIPS64R6-ABS2K8-NEXT:    abs.d $f0, $f12
;
; MM-LABEL: foo:
; MM:       # %bb.0: # %entry
; MM-NEXT:    jr $ra
; MM-NEXT:    abs.d $f0, $f12
;
; MM-ABS2K8-LABEL: foo:
; MM-ABS2K8:       # %bb.0: # %entry
; MM-ABS2K8-NEXT:    jr $ra
; MM-ABS2K8-NEXT:    abs.d $f0, $f12
;
; MMR6-LABEL: foo:
; MMR6:       # %bb.0: # %entry
; MMR6-NEXT:    abs.d $f0, $f12
; MMR6-NEXT:    jrc $ra
entry:
  %0 = tail call fast double @llvm.fabs.f64(double %a)
  ret double %0
}

define dso_local double @bar(double %a) {
; MIPS32R1-LABEL: bar:
; MIPS32R1:       # %bb.0: # %entry
; MIPS32R1-NEXT:    lui $1, 32767
; MIPS32R1-NEXT:    ori $1, $1, 65535
; MIPS32R1-NEXT:    mfc1 $2, $f13
; MIPS32R1-NEXT:    and $1, $2, $1
; MIPS32R1-NEXT:    mfc1 $2, $f12
; MIPS32R1-NEXT:    mtc1 $2, $f0
; MIPS32R1-NEXT:    jr $ra
; MIPS32R1-NEXT:    mtc1 $1, $f1
;
; MIPS32R2-LABEL: bar:
; MIPS32R2:       # %bb.0: # %entry
; MIPS32R2-NEXT:    mfc1 $1, $f12
; MIPS32R2-NEXT:    mfhc1 $2, $f12
; MIPS32R2-NEXT:    ins $2, $zero, 31, 1
; MIPS32R2-NEXT:    mtc1 $1, $f0
; MIPS32R2-NEXT:    mthc1 $2, $f0
; MIPS32R2-NEXT:    jr $ra
; MIPS32R2-NEXT:    nop
;
; MIPS32R2-ABS2K8-LABEL: bar:
; MIPS32R2-ABS2K8:       # %bb.0: # %entry
; MIPS32R2-ABS2K8-NEXT:    jr $ra
; MIPS32R2-ABS2K8-NEXT:    abs.d $f0, $f12
;
; MIPS32R6-LABEL: bar:
; MIPS32R6:       # %bb.0: # %entry
; MIPS32R6-NEXT:    jr $ra
; MIPS32R6-NEXT:    abs.d $f0, $f12
;
; MIPS64R1-LABEL: bar:
; MIPS64R1:       # %bb.0: # %entry
; MIPS64R1-NEXT:    dmfc1 $1, $f12
; MIPS64R1-NEXT:    daddiu $2, $zero, 1
; MIPS64R1-NEXT:    dsll $2, $2, 63
; MIPS64R1-NEXT:    daddiu $2, $2, -1
; MIPS64R1-NEXT:    and $1, $1, $2
; MIPS64R1-NEXT:    jr $ra
; MIPS64R1-NEXT:    dmtc1 $1, $f0
;
; MIPS64R2-LABEL: bar:
; MIPS64R2:       # %bb.0: # %entry
; MIPS64R2-NEXT:    dmfc1 $1, $f12
; MIPS64R2-NEXT:    dinsu $1, $zero, 63, 1
; MIPS64R2-NEXT:    jr $ra
; MIPS64R2-NEXT:    dmtc1 $1, $f0
;
; MIPS64R2-ABS2K8-LABEL: bar:
; MIPS64R2-ABS2K8:       # %bb.0: # %entry
; MIPS64R2-ABS2K8-NEXT:    jr $ra
; MIPS64R2-ABS2K8-NEXT:    abs.d $f0, $f12
;
; MIPS64R6-LABEL: bar:
; MIPS64R6:       # %bb.0: # %entry
; MIPS64R6-NEXT:    jr $ra
; MIPS64R6-NEXT:    abs.d $f0, $f12
;
; MIPS64R6-ABS2K8-LABEL: bar:
; MIPS64R6-ABS2K8:       # %bb.0: # %entry
; MIPS64R6-ABS2K8-NEXT:    jr $ra
; MIPS64R6-ABS2K8-NEXT:    abs.d $f0, $f12
;
; MM-LABEL: bar:
; MM:       # %bb.0: # %entry
; MM-NEXT:    mfc1 $1, $f12
; MM-NEXT:    mfhc1 $2, $f12
; MM-NEXT:    ins $2, $zero, 31, 1
; MM-NEXT:    mtc1 $1, $f0
; MM-NEXT:    mthc1 $2, $f0
; MM-NEXT:    jrc $ra
;
; MM-ABS2K8-LABEL: bar:
; MM-ABS2K8:       # %bb.0: # %entry
; MM-ABS2K8-NEXT:    jr $ra
; MM-ABS2K8-NEXT:    abs.d $f0, $f12
;
; MMR6-LABEL: bar:
; MMR6:       # %bb.0: # %entry
; MMR6-NEXT:    abs.d $f0, $f12
; MMR6-NEXT:    jrc $ra
entry:
  %0 = tail call fast double @llvm.fabs.f64(double %a)
  ret double %0
}

define dso_local float @foo_2(float %a) #0 {
; MIPS32R1-LABEL: foo_2:
; MIPS32R1:       # %bb.0: # %entry
; MIPS32R1-NEXT:    jr $ra
; MIPS32R1-NEXT:    abs.s $f0, $f12
;
; MIPS32R2-LABEL: foo_2:
; MIPS32R2:       # %bb.0: # %entry
; MIPS32R2-NEXT:    jr $ra
; MIPS32R2-NEXT:    abs.s $f0, $f12
;
; MIPS32R2-ABS2K8-LABEL: foo_2:
; MIPS32R2-ABS2K8:       # %bb.0: # %entry
; MIPS32R2-ABS2K8-NEXT:    jr $ra
; MIPS32R2-ABS2K8-NEXT:    abs.s $f0, $f12
;
; MIPS32R6-LABEL: foo_2:
; MIPS32R6:       # %bb.0: # %entry
; MIPS32R6-NEXT:    jr $ra
; MIPS32R6-NEXT:    abs.s $f0, $f12
;
; MIPS64R1-LABEL: foo_2:
; MIPS64R1:       # %bb.0: # %entry
; MIPS64R1-NEXT:    jr $ra
; MIPS64R1-NEXT:    abs.s $f0, $f12
;
; MIPS64R2-LABEL: foo_2:
; MIPS64R2:       # %bb.0: # %entry
; MIPS64R2-NEXT:    jr $ra
; MIPS64R2-NEXT:    abs.s $f0, $f12
;
; MIPS64R2-ABS2K8-LABEL: foo_2:
; MIPS64R2-ABS2K8:       # %bb.0: # %entry
; MIPS64R2-ABS2K8-NEXT:    jr $ra
; MIPS64R2-ABS2K8-NEXT:    abs.s $f0, $f12
;
; MIPS64R6-LABEL: foo_2:
; MIPS64R6:       # %bb.0: # %entry
; MIPS64R6-NEXT:    jr $ra
; MIPS64R6-NEXT:    abs.s $f0, $f12
;
; MIPS64R6-ABS2K8-LABEL: foo_2:
; MIPS64R6-ABS2K8:       # %bb.0: # %entry
; MIPS64R6-ABS2K8-NEXT:    jr $ra
; MIPS64R6-ABS2K8-NEXT:    abs.s $f0, $f12
;
; MM-LABEL: foo_2:
; MM:       # %bb.0: # %entry
; MM-NEXT:    jr $ra
; MM-NEXT:    abs.s $f0, $f12
;
; MM-ABS2K8-LABEL: foo_2:
; MM-ABS2K8:       # %bb.0: # %entry
; MM-ABS2K8-NEXT:    jr $ra
; MM-ABS2K8-NEXT:    abs.s $f0, $f12
;
; MMR6-LABEL: foo_2:
; MMR6:       # %bb.0: # %entry
; MMR6-NEXT:    abs.s $f0, $f12
; MMR6-NEXT:    jrc $ra
entry:
  %0 = tail call fast float @llvm.fabs.f32(float %a)
  ret float %0
}

define dso_local float @bar_2(float %a) {
; MIPS32R1-LABEL: bar_2:
; MIPS32R1:       # %bb.0: # %entry
; MIPS32R1-NEXT:    lui $1, 32767
; MIPS32R1-NEXT:    ori $1, $1, 65535
; MIPS32R1-NEXT:    mfc1 $2, $f12
; MIPS32R1-NEXT:    and $1, $2, $1
; MIPS32R1-NEXT:    jr $ra
; MIPS32R1-NEXT:    mtc1 $1, $f0
;
; MIPS32R2-LABEL: bar_2:
; MIPS32R2:       # %bb.0: # %entry
; MIPS32R2-NEXT:    mfc1 $1, $f12
; MIPS32R2-NEXT:    ins $1, $zero, 31, 1
; MIPS32R2-NEXT:    jr $ra
; MIPS32R2-NEXT:    mtc1 $1, $f0
;
; MIPS32R2-ABS2K8-LABEL: bar_2:
; MIPS32R2-ABS2K8:       # %bb.0: # %entry
; MIPS32R2-ABS2K8-NEXT:    jr $ra
; MIPS32R2-ABS2K8-NEXT:    abs.s $f0, $f12
;
; MIPS32R6-LABEL: bar_2:
; MIPS32R6:       # %bb.0: # %entry
; MIPS32R6-NEXT:    jr $ra
; MIPS32R6-NEXT:    abs.s $f0, $f12
;
; MIPS64R1-LABEL: bar_2:
; MIPS64R1:       # %bb.0: # %entry
; MIPS64R1-NEXT:    lui $1, 32767
; MIPS64R1-NEXT:    ori $1, $1, 65535
; MIPS64R1-NEXT:    mfc1 $2, $f12
; MIPS64R1-NEXT:    and $1, $2, $1
; MIPS64R1-NEXT:    jr $ra
; MIPS64R1-NEXT:    mtc1 $1, $f0
;
; MIPS64R2-LABEL: bar_2:
; MIPS64R2:       # %bb.0: # %entry
; MIPS64R2-NEXT:    mfc1 $1, $f12
; MIPS64R2-NEXT:    ins $1, $zero, 31, 1
; MIPS64R2-NEXT:    jr $ra
; MIPS64R2-NEXT:    mtc1 $1, $f0
;
; MIPS64R2-ABS2K8-LABEL: bar_2:
; MIPS64R2-ABS2K8:       # %bb.0: # %entry
; MIPS64R2-ABS2K8-NEXT:    jr $ra
; MIPS64R2-ABS2K8-NEXT:    abs.s $f0, $f12
;
; MIPS64R6-LABEL: bar_2:
; MIPS64R6:       # %bb.0: # %entry
; MIPS64R6-NEXT:    jr $ra
; MIPS64R6-NEXT:    abs.s $f0, $f12
;
; MIPS64R6-ABS2K8-LABEL: bar_2:
; MIPS64R6-ABS2K8:       # %bb.0: # %entry
; MIPS64R6-ABS2K8-NEXT:    jr $ra
; MIPS64R6-ABS2K8-NEXT:    abs.s $f0, $f12
;
; MM-LABEL: bar_2:
; MM:       # %bb.0: # %entry
; MM-NEXT:    mfc1 $1, $f12
; MM-NEXT:    ins $1, $zero, 31, 1
; MM-NEXT:    jr $ra
; MM-NEXT:    mtc1 $1, $f0
;
; MM-ABS2K8-LABEL: bar_2:
; MM-ABS2K8:       # %bb.0: # %entry
; MM-ABS2K8-NEXT:    jr $ra
; MM-ABS2K8-NEXT:    abs.s $f0, $f12
;
; MMR6-LABEL: bar_2:
; MMR6:       # %bb.0: # %entry
; MMR6-NEXT:    abs.s $f0, $f12
; MMR6-NEXT:    jrc $ra
entry:
  %0 = tail call fast float @llvm.fabs.f32(float %a)
  ret float %0
}

attributes #0 = { nounwind "no-nans-fp-math"="true" }