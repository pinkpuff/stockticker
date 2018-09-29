WaitFrame:
   inc Sleeping
@WaitFrameLoop:
   lda Sleeping
   bne @WaitFrameLoop
   rts
