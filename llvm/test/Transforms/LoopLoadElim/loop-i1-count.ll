; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -S -passes=loop-load-elim %s | FileCheck %s

; The backedge taken count of this loop is an i1 type, and the IV is i8.
; The math in LoopAccessAnalysis was rounding the type sizes to bytes and
; believing them equal, causing a size mismatch.

target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"

@a = external dso_local local_unnamed_addr global [1 x i32], align 4

define dso_local void @test(i8 %inc) local_unnamed_addr {
; CHECK-LABEL: @test(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[FOR_COND3:%.*]]
; CHECK:       for.cond3:
; CHECK-NEXT:    [[H_0:%.*]] = phi i8 [ 0, [[ENTRY:%.*]] ], [ [[ADD:%.*]], [[COND_END_FOR_COND_CLEANUP_LOOPEXIT_CRIT_EDGE:%.*]] ]
; CHECK-NEXT:    [[IDXPROM11:%.*]] = sext i8 [[H_0]] to i64
; CHECK-NEXT:    [[ARRAYIDX27:%.*]] = getelementptr inbounds [1 x i32], [1 x i32]* @a, i64 0, i64 [[IDXPROM11]]
; CHECK-NEXT:    br label [[FOR_BODY:%.*]]
; CHECK:       cond.end.for.cond.cleanup.loopexit_crit_edge:
; CHECK-NEXT:    [[ADD]] = add i8 [[H_0]], [[INC:%.*]]
; CHECK-NEXT:    br label [[FOR_COND3]]
; CHECK:       for.body:
; CHECK-NEXT:    store i32 0, i32* [[ARRAYIDX27]], align 4
; CHECK-NEXT:    br i1 true, label [[COND_END_FOR_COND_CLEANUP_LOOPEXIT_CRIT_EDGE]], label [[FOR_BODY]]
;
entry:
  br label %for.cond3

for.cond3:                                        ; preds = %cond.end.for.cond.cleanup.loopexit_crit_edge, %entry
  %h.0 = phi i8 [ 0, %entry ], [ %add, %cond.end.for.cond.cleanup.loopexit_crit_edge ]
  %idxprom11 = sext i8 %h.0 to i64
  %arrayidx27 = getelementptr inbounds [1 x i32], [1 x i32]* @a, i64 0, i64 %idxprom11
  br label %for.body

cond.end.for.cond.cleanup.loopexit_crit_edge:     ; preds = %for.body
  %add = add i8 %h.0, %inc
  br label %for.cond3

for.body:                                         ; preds = %for.body, %for.cond3
  store i32 0, i32* %arrayidx27, align 4
  br i1 true, label %cond.end.for.cond.cleanup.loopexit_crit_edge, label %for.body
}