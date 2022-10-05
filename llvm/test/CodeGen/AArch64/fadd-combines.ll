; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=aarch64-none-linux-gnu -verify-machineinstrs | FileCheck %s

define double @test1(double %a, double %b) {
; CHECK-LABEL: test1:
; CHECK:       // %bb.0:
; CHECK-NEXT:    fadd d1, d1, d1
; CHECK-NEXT:    fsub d0, d0, d1
; CHECK-NEXT:    ret
  %mul = fmul double %b, -2.000000e+00
  %add1 = fadd double %a, %mul
  ret double %add1
}

; DAGCombine will canonicalize 'a - 2.0*b' to 'a + -2.0*b'

define double @test2(double %a, double %b) {
; CHECK-LABEL: test2:
; CHECK:       // %bb.0:
; CHECK-NEXT:    fadd d1, d1, d1
; CHECK-NEXT:    fsub d0, d0, d1
; CHECK-NEXT:    ret
  %mul = fmul double %b, 2.000000e+00
  %add1 = fsub double %a, %mul
  ret double %add1
}

define double @test3(double %a, double %b, double %c) {
; CHECK-LABEL: test3:
; CHECK:       // %bb.0:
; CHECK-NEXT:    fadd d2, d2, d2
; CHECK-NEXT:    fmul d0, d0, d1
; CHECK-NEXT:    fsub d0, d0, d2
; CHECK-NEXT:    ret
  %mul = fmul double %a, %b
  %mul1 = fmul double %c, 2.000000e+00
  %sub = fsub double %mul, %mul1
  ret double %sub
}

define double @test4(double %a, double %b, double %c) {
; CHECK-LABEL: test4:
; CHECK:       // %bb.0:
; CHECK-NEXT:    fadd d2, d2, d2
; CHECK-NEXT:    fmul d0, d0, d1
; CHECK-NEXT:    fsub d0, d0, d2
; CHECK-NEXT:    ret
  %mul = fmul double %a, %b
  %mul1 = fmul double %c, -2.000000e+00
  %add2 = fadd double %mul, %mul1
  ret double %add2
}

define <4 x float> @fmulnegtwo_vec(<4 x float> %a, <4 x float> %b) {
; CHECK-LABEL: fmulnegtwo_vec:
; CHECK:       // %bb.0:
; CHECK-NEXT:    fadd v1.4s, v1.4s, v1.4s
; CHECK-NEXT:    fsub v0.4s, v0.4s, v1.4s
; CHECK-NEXT:    ret
  %mul = fmul <4 x float> %b, <float -2.0, float -2.0, float -2.0, float -2.0>
  %add = fadd <4 x float> %a, %mul
  ret <4 x float> %add
}

define <4 x float> @fmulnegtwo_vec_commute(<4 x float> %a, <4 x float> %b) {
; CHECK-LABEL: fmulnegtwo_vec_commute:
; CHECK:       // %bb.0:
; CHECK-NEXT:    fadd v1.4s, v1.4s, v1.4s
; CHECK-NEXT:    fsub v0.4s, v0.4s, v1.4s
; CHECK-NEXT:    ret
  %mul = fmul <4 x float> %b, <float -2.0, float -2.0, float -2.0, float -2.0>
  %add = fadd <4 x float> %mul, %a
  ret <4 x float> %add
}

define <4 x float> @fmulnegtwo_vec_undefs(<4 x float> %a, <4 x float> %b) {
; CHECK-LABEL: fmulnegtwo_vec_undefs:
; CHECK:       // %bb.0:
; CHECK-NEXT:    fadd v1.4s, v1.4s, v1.4s
; CHECK-NEXT:    fsub v0.4s, v0.4s, v1.4s
; CHECK-NEXT:    ret
  %mul = fmul <4 x float> %b, <float undef, float -2.0, float undef, float -2.0>
  %add = fadd <4 x float> %a, %mul
  ret <4 x float> %add
}

define <4 x float> @fmulnegtwo_vec_commute_undefs(<4 x float> %a, <4 x float> %b) {
; CHECK-LABEL: fmulnegtwo_vec_commute_undefs:
; CHECK:       // %bb.0:
; CHECK-NEXT:    fadd v1.4s, v1.4s, v1.4s
; CHECK-NEXT:    fsub v0.4s, v0.4s, v1.4s
; CHECK-NEXT:    ret
  %mul = fmul <4 x float> %b, <float -2.0, float undef, float -2.0, float -2.0>
  %add = fadd <4 x float> %mul, %a
  ret <4 x float> %add
}

define <4 x float> @test6(<4 x float> %a, <4 x float> %b) {
; CHECK-LABEL: test6:
; CHECK:       // %bb.0:
; CHECK-NEXT:    fadd v1.4s, v1.4s, v1.4s
; CHECK-NEXT:    fsub v0.4s, v0.4s, v1.4s
; CHECK-NEXT:    ret
  %mul = fmul <4 x float> %b, <float 2.0, float 2.0, float 2.0, float 2.0>
  %add = fsub <4 x float> %a, %mul
  ret <4 x float> %add
}

; Don't fold (fadd A, (fmul B, -2.0)) -> (fsub A, (fadd B, B)) if the fmul has
; multiple uses.

define double @test7(double %a, double %b) nounwind {
; CHECK-LABEL: test7:
; CHECK:       // %bb.0:
; CHECK-NEXT:    str d8, [sp, #-16]! // 8-byte Folded Spill
; CHECK-NEXT:    fmov d2, #-2.00000000
; CHECK-NEXT:    str x30, [sp, #8] // 8-byte Folded Spill
; CHECK-NEXT:    fmul d1, d1, d2
; CHECK-NEXT:    fadd d8, d0, d1
; CHECK-NEXT:    fmov d0, d1
; CHECK-NEXT:    bl use
; CHECK-NEXT:    ldr x30, [sp, #8] // 8-byte Folded Reload
; CHECK-NEXT:    fmov d0, d8
; CHECK-NEXT:    ldr d8, [sp], #16 // 8-byte Folded Reload
; CHECK-NEXT:    ret
  %mul = fmul double %b, -2.000000e+00
  %add1 = fadd double %a, %mul
  call void @use(double %mul)
  ret double %add1
}

define float @fadd_const_multiuse_fmf(float %x) {
; CHECK-LABEL: fadd_const_multiuse_fmf:
; CHECK:       // %bb.0:
; CHECK-NEXT:    mov w8, #1109917696
; CHECK-NEXT:    mov w9, #1114374144
; CHECK-NEXT:    fmov s1, w8
; CHECK-NEXT:    fmov s2, w9
; CHECK-NEXT:    fadd s1, s0, s1
; CHECK-NEXT:    fadd s0, s0, s2
; CHECK-NEXT:    fadd s0, s1, s0
; CHECK-NEXT:    ret
  %a1 = fadd float %x, 42.0
  %a2 = fadd nsz reassoc float %a1, 17.0
  %a3 = fadd float %a1, %a2
  ret float %a3
}

; DAGCombiner transforms this into: (x + 17.0) + (x + 59.0).
define float @fadd_const_multiuse_attr(float %x) {
; CHECK-LABEL: fadd_const_multiuse_attr:
; CHECK:       // %bb.0:
; CHECK-NEXT:    mov w8, #1109917696
; CHECK-NEXT:    mov w9, #1114374144
; CHECK-NEXT:    fmov s1, w8
; CHECK-NEXT:    fmov s2, w9
; CHECK-NEXT:    fadd s1, s0, s1
; CHECK-NEXT:    fadd s0, s0, s2
; CHECK-NEXT:    fadd s0, s1, s0
; CHECK-NEXT:    ret
  %a1 = fadd fast float %x, 42.0
  %a2 = fadd fast float %a1, 17.0
  %a3 = fadd fast float %a1, %a2
  ret float %a3
}

; PR32939 - https://bugs.llvm.org/show_bug.cgi?id=32939

define double @fmul2_negated(double %a, double %b, double %c) {
; CHECK-LABEL: fmul2_negated:
; CHECK:       // %bb.0:
; CHECK-NEXT:    fadd d1, d1, d1
; CHECK-NEXT:    fmul d1, d1, d2
; CHECK-NEXT:    fsub d0, d0, d1
; CHECK-NEXT:    ret
  %mul = fmul double %b, 2.0
  %mul1 = fmul double %mul, %c
  %sub = fsub double %a, %mul1
  ret double %sub
}

define <2 x double> @fmul2_negated_vec(<2 x double> %a, <2 x double> %b, <2 x double> %c) {
; CHECK-LABEL: fmul2_negated_vec:
; CHECK:       // %bb.0:
; CHECK-NEXT:    fadd v1.2d, v1.2d, v1.2d
; CHECK-NEXT:    fmul v1.2d, v1.2d, v2.2d
; CHECK-NEXT:    fsub v0.2d, v0.2d, v1.2d
; CHECK-NEXT:    ret
  %mul = fmul <2 x double> %b, <double 2.0, double 2.0>
  %mul1 = fmul <2 x double> %mul, %c
  %sub = fsub <2 x double> %a, %mul1
  ret <2 x double> %sub
}

; ((a*b) + (c*d)) + n1 --> (a*b) + ((c*d) + n1)

define double @fadd_fma_fmul_1(double %a, double %b, double %c, double %d, double %n1) nounwind {
; CHECK-LABEL: fadd_fma_fmul_1:
; CHECK:       // %bb.0:
; CHECK-NEXT:    fmadd d2, d2, d3, d4
; CHECK-NEXT:    fmadd d0, d0, d1, d2
; CHECK-NEXT:    ret
  %m1 = fmul fast double %a, %b
  %m2 = fmul fast double %c, %d
  %a1 = fadd fast double %m1, %m2
  %a2 = fadd fast double %a1, %n1
  ret double %a2
}

; Minimum FMF - the 1st fadd is contracted because that combines
; fmul+fadd as specified by the order of operations; the 2nd fadd
; requires reassociation to fuse with c*d.

define float @fadd_fma_fmul_fmf(float %a, float %b, float %c, float %d, float %n0) nounwind {
; CHECK-LABEL: fadd_fma_fmul_fmf:
; CHECK:       // %bb.0:
; CHECK-NEXT:    fmadd s2, s2, s3, s4
; CHECK-NEXT:    fmadd s0, s0, s1, s2
; CHECK-NEXT:    ret
  %m1 = fmul contract float %a, %b
  %m2 = fmul contract float %c, %d
  %a1 = fadd contract float %m1, %m2
  %a2 = fadd contract reassoc float %n0, %a1
  ret float %a2
}

; Not minimum FMF.

define float @fadd_fma_fmul_2(float %a, float %b, float %c, float %d, float %n0) nounwind {
; CHECK-LABEL: fadd_fma_fmul_2:
; CHECK:       // %bb.0:
; CHECK-NEXT:    fmul s2, s2, s3
; CHECK-NEXT:    fmadd s0, s0, s1, s2
; CHECK-NEXT:    fadd s0, s4, s0
; CHECK-NEXT:    ret
  %m1 = fmul float %a, %b
  %m2 = fmul float %c, %d
  %a1 = fadd contract float %m1, %m2
  %a2 = fadd contract float %n0, %a1
  ret float %a2
}

; The final fadd can be folded with either 1 of the leading fmuls.

define <2 x double> @fadd_fma_fmul_3(<2 x double> %x1, <2 x double> %x2, <2 x double> %x3, <2 x double> %x4, <2 x double> %x5, <2 x double> %x6, <2 x double> %x7, <2 x double> %x8) nounwind {
; CHECK-LABEL: fadd_fma_fmul_3:
; CHECK:       // %bb.0:
; CHECK-NEXT:    fmul v2.2d, v2.2d, v3.2d
; CHECK-NEXT:    fmla v2.2d, v1.2d, v0.2d
; CHECK-NEXT:    fmla v2.2d, v7.2d, v6.2d
; CHECK-NEXT:    fmla v2.2d, v5.2d, v4.2d
; CHECK-NEXT:    mov v0.16b, v2.16b
; CHECK-NEXT:    ret
  %m1 = fmul fast <2 x double> %x1, %x2
  %m2 = fmul fast <2 x double> %x3, %x4
  %m3 = fmul fast <2 x double> %x5, %x6
  %m4 = fmul fast <2 x double> %x7, %x8
  %a1 = fadd fast <2 x double> %m1, %m2
  %a2 = fadd fast <2 x double> %m3, %m4
  %a3 = fadd fast <2 x double> %a1, %a2
  ret <2 x double> %a3
}

; negative test

define float @fadd_fma_fmul_extra_use_1(float %a, float %b, float %c, float %d, float %n0, float* %p) nounwind {
; CHECK-LABEL: fadd_fma_fmul_extra_use_1:
; CHECK:       // %bb.0:
; CHECK-NEXT:    fmul s1, s0, s1
; CHECK-NEXT:    fmadd s0, s2, s3, s1
; CHECK-NEXT:    str s1, [x0]
; CHECK-NEXT:    fadd s0, s4, s0
; CHECK-NEXT:    ret
  %m1 = fmul fast float %a, %b
  store float %m1, float* %p
  %m2 = fmul fast float %c, %d
  %a1 = fadd fast float %m1, %m2
  %a2 = fadd fast float %n0, %a1
  ret float %a2
}

; negative test

define float @fadd_fma_fmul_extra_use_2(float %a, float %b, float %c, float %d, float %n0, float* %p) nounwind {
; CHECK-LABEL: fadd_fma_fmul_extra_use_2:
; CHECK:       // %bb.0:
; CHECK-NEXT:    fmul s2, s2, s3
; CHECK-NEXT:    fmadd s0, s0, s1, s2
; CHECK-NEXT:    str s2, [x0]
; CHECK-NEXT:    fadd s0, s4, s0
; CHECK-NEXT:    ret
  %m1 = fmul fast float %a, %b
  %m2 = fmul fast float %c, %d
  store float %m2, float* %p
  %a1 = fadd fast float %m1, %m2
  %a2 = fadd fast float %n0, %a1
  ret float %a2
}

; negative test

define float @fadd_fma_fmul_extra_use_3(float %a, float %b, float %c, float %d, float %n0, float* %p) nounwind {
; CHECK-LABEL: fadd_fma_fmul_extra_use_3:
; CHECK:       // %bb.0:
; CHECK-NEXT:    fmul s2, s2, s3
; CHECK-NEXT:    fmadd s1, s0, s1, s2
; CHECK-NEXT:    fadd s0, s4, s1
; CHECK-NEXT:    str s1, [x0]
; CHECK-NEXT:    ret
  %m1 = fmul fast float %a, %b
  %m2 = fmul fast float %c, %d
  %a1 = fadd fast float %m1, %m2
  store float %a1, float* %p
  %a2 = fadd fast float %n0, %a1
  ret float %a2
}

declare void @use(double)
