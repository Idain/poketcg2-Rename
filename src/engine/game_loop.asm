GameLoop::
	di
	ld sp, $d000
	call ResetSerial
	call EnableInt_VBlank
	call EnableInt_Timer
	call EnableSRAM
	ld a, [$a006] ; sTextSpeed
	ld [$cdde], a ; wTextSpeed
	ld a, [$a009] ; sSkipDelayAllowed
	ld [$cd08], a ; wSkipDelayAllowed
	call DisableSRAM
	ld a, DECK_SIZE
	ld [wDeckSize], a
	ei

	ld a, [wConsole]
	cp CONSOLE_CGB
	jr nz, .not_cgb
	call ReadJoypad
	ldh a, [hKeysHeld]
	cp A_BUTTON | B_BUTTON
	jr z, .ask_erase_backup_ram
	farcall $4, CoreGameLoop ; unnecessary farcall?
	jr GameLoop

.not_cgb
	farcall GBCOnlyDisclaimer
	ret

.ask_erase_backup_ram
	call SetupResetBackUpRAMScreen
	call EmptyScreen
	ldtx hl, Text00a9
	call YesOrNoMenuWithText
	jr c, .reset_game
; erase sram
	call EnableSRAM
	xor a
	ld [s0a000], a
	call DisableSRAM
.reset_game
	jp Reset

Func_405b:
	farcall $6, $58f8
	ret

SetupResetBackUpRAMScreen:
	xor a ; SYM_SPACE
	ld [wTileMapFill], a
	call DisableLCD
	call LoadSymbolsFont
	call SetDefaultPalettes
	lb de, $38, $7f
	call SetupText
	ret
