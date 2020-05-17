; ---------------------------------------------------------------------------
; Animation script - Tails
; ---------------------------------------------------------------------------
Ani_Tails:
		dc.w TailAni_Null-Ani_Tails
		dc.w TailAni_Walk-Ani_Tails
		dc.w TailAni_Run-Ani_Tails
		dc.w TailAni_Dash-Ani_Tails
		dc.w TailAni_Roll-Ani_Tails
		dc.w TailAni_Roll2-Ani_Tails
		dc.w TailAni_Push-Ani_Tails
		dc.w TailAni_Wait-Ani_Tails
		dc.w TailAni_Balance-Ani_Tails
		dc.w TailAni_Balance-Ani_Tails ; FORWARD
		dc.w TailAni_Balance-Ani_Tails ; BACKWARD
		dc.w TailAni_LookUp-Ani_Tails
		dc.w TailAni_Duck-Ani_Tails
		dc.w TailAni_Spindash-Ani_Tails
		dc.w TailAni_Stop-Ani_Tails
		dc.w TailAni_Float1-Ani_Tails
		dc.w TailAni_Float2-Ani_Tails
		dc.w TailAni_Float3-Ani_Tails
		dc.w TailAni_Float4-Ani_Tails
		dc.w TailAni_Spring-Ani_Tails
		dc.w TailAni_Hang-Ani_Tails
		dc.w TailAni_Null-Ani_Tails ; Fall
		dc.w TailAni_GetAir-Ani_Tails
		dc.w TailAni_GetAir-Ani_Tails ; Standing bubble
		dc.w TailAni_Death-Ani_Tails
		dc.w TailAni_Drown-Ani_Tails
		dc.w TailAni_Shrink-Ani_Tails
		dc.w TailAni_Hurt-Ani_Tails
		dc.w TailAni_WaterSlide-Ani_Tails
		dc.w TailAni_Null-Ani_Tails ; Transform
		dc.w TailAni_Fly-Ani_Tails
		dc.w TailAni_FlyTired-Ani_Tails
		dc.w TailAni_Swim-Ani_Tails
		dc.w TailAni_SwimUp-Ani_Tails
		dc.w TailAni_SwimTired-Ani_Tails

TailAni_Null:	dc.b $77, fr_TailNull, afChange, aniID_Walk
		even
TailAni_Walk:	dc.b $FF, fr_TailWalk13, fr_TailWalk14, fr_TailWalk15, fr_TailWalk16, fr_TailWalk17, fr_TailWalk18, fr_TailWalk11, fr_TailWalk12, afEnd
		even
TailAni_Run:	dc.b $FF, fr_TailRun11, fr_TailRun12, fr_TailRun13, fr_TailRun14, afEnd, afEnd, afEnd, afEnd, afEnd
		even
TailAni_Dash:	dc.b $FF, fr_TailRun15, fr_TailRun16, afEnd
		even
TailAni_Roll:	dc.b $FE, fr_TailRoll3,fr_TailRoll2,fr_TailRoll1, afEnd
		even
TailAni_Roll2:	dc.b $FE, fr_TailRoll3,fr_TailRoll2,fr_TailRoll1, afEnd
		even
TailAni_Push:	dc.b $FD, fr_TailPush1,fr_TailPush2,fr_TailPush3,fr_TailPush4,$FF,$FF,$FF,$FF, afEnd
		even
TailAni_Wait:	dc.b   7,  fr_TailStand1,  fr_TailStand1,  fr_TailStand1,  fr_TailStand1,  fr_TailStand1,  fr_TailStand1,  fr_TailStand1,  fr_TailStand1,  fr_TailStand1,  fr_TailStand1,  fr_TailStand3,  fr_TailStand2,  fr_TailStand1,  fr_TailStand1,  fr_TailStand1
		dc.b   fr_TailStand1,  fr_TailStand1,  fr_TailStand1,  fr_TailStand1,  fr_TailStand1,  fr_TailStand3,  fr_TailStand2,  fr_TailStand1,  fr_TailStand1,  fr_TailStand1,  fr_TailStand1,  fr_TailStand1,  fr_TailStand1,  fr_TailStand1,  fr_TailStand1,  fr_TailStand1
		dc.b   fr_TailIdle1,  fr_TailIdle1,  fr_TailIdle1,  fr_TailIdle1,  fr_TailIdle1,  fr_TailIdle1,  fr_TailIdle1,  fr_TailIdle1,  fr_TailIdle1,  fr_TailIdle1,  fr_TailIdle1,  fr_TailIdle1,  fr_TailIdle1,  fr_TailIdle1,  fr_TailIdle1,  fr_TailIdle1
		dc.b   fr_TailIdle2,  fr_TailIdle3,  fr_TailIdle4,  fr_TailIdle3,  fr_TailIdle4,  fr_TailIdle3,  fr_TailIdle4,  fr_TailIdle3,  fr_TailIdle4,  fr_TailIdle3,  fr_TailIdle4,  fr_TailIdle2, afBack, $1C
		even
TailAni_Balance:	dc.b 9,fr_TailBalance1,fr_TailBalance1,fr_TailBalance2,fr_TailBalance2,fr_TailBalance1,fr_TailBalance1,fr_TailBalance2,fr_TailBalance2,fr_TailBalance1,fr_TailBalance1,fr_TailBalance2,fr_TailBalance2,fr_TailBalance1,fr_TailBalance1,fr_TailBalance2,fr_TailBalance2
			dc.b fr_TailBalance1,fr_TailBalance1,fr_TailBalance2,fr_TailBalance2,fr_TailBalance1,fr_TailBalance2, afEnd
		even
TailAni_LookUp:	dc.b $3F, fr_TailLookUp, afEnd
		even
TailAni_Duck:	dc.b $3F, fr_TailDuck, afEnd
		even
TailAni_Spindash:	dc.b 0, fr_TailSpindash1, fr_TailSpindash2, fr_TailSpindash3, afEnd
		even
TailAni_Stop:	dc.b 7, fr_TailStop1, fr_TailStop2, fr_TailStop1, fr_TailStop2, afChange, aniID_Walk
		even
TailAni_Float1:	dc.b 9, fr_TailFloat1, fr_TailFloat6, afEnd
		even
TailAni_Float2:	dc.b 9, fr_TailFloat1, fr_TailFloat2, fr_TailFloat3, fr_TailFloat4, fr_TailFloat5, afEnd
		even
TailAni_Float3:	dc.b 3,	fr_TailRun33, fr_TailRun34, 0, fr_TailRun35, 0, afEnd
		even
TailAni_Float4:	dc.b 3,	fr_TailFloat1, afChange, aniID_Walk
		even
TailAni_Spring:	dc.b 3, fr_TailSpring1, fr_TailSpring2, fr_TailSpring1, fr_TailSpring2, fr_TailSpring1, fr_TailSpring2, fr_TailSpring1, fr_TailSpring2, fr_TailSpring1, fr_TailSpring2, fr_TailSpring1, fr_TailSpring2, afChange, aniID_Walk
		even
TailAni_Hang:	dc.b 5,	fr_TailHang1, fr_TailHang2, afEnd
		even
TailAni_GetAir:	dc.b $B, fr_TailGetAir, fr_TailGetAir, fr_TailWalk15, fr_TailWalk16, afChange, aniID_Walk
		even
TailAni_Death:	dc.b 3,	fr_TailDeath, afEnd
		even
TailAni_Drown:	dc.b $2F, fr_TailDeath, afEnd
		even
TailAni_Shrink:	dc.b 3,	fr_TailDeath, fr_TailDeath, fr_TailDeath, fr_TailDeath, fr_TailDeath, fr_TailNull, afBack, 1
		even
TailAni_Hurt:	dc.b 3,	fr_TailHurt, afEnd
		even
TailAni_WaterSlide:
		dc.b 7, fr_TailWaterSlide, fr_TailHurt, afEnd
		even
TailAni_Fly:	dc.b 1, fr_TailFly1, fr_TailFly2, afEnd
		even
TailAni_FlyTired: dc.b $B, fr_TailFlyTired1, fr_TailFlyTired2, afEnd
		even
TailAni_Swim:	dc.b 7, fr_TailSwim1, fr_TailSwim2, fr_TailSwim3, fr_TailSwim4, fr_TailSwim5, afEnd
		even
TailAni_SwimUp:	dc.b 3, fr_TailSwim1, fr_TailSwim2, fr_TailSwim3, fr_TailSwim4, fr_TailSwim5, afEnd
		even
TailAni_SwimTired: dc.b $B, fr_TailSwimTired1, fr_TailSwimTired2, fr_TailSwimTired3, afEnd
		even