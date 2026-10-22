extends Node

enum GameState { DEFAULT, AUTOPLAY, SPEEDUP, PAUSED, TRANSITION, SHOWING_CG }
enum LineStatus { OK, CHOICE, GAME, EXIT }

const COMMAND_CHARACTER := "character"
const COMMAND_BACKGROUND := "background"
const COMMAND_BGM := "bgm"
const COMMAND_EFFECT := "effect"
const COMMAND_CHUBBY := "chubby"
const COMMAND_CG := "CG"
const COMMAND_SOUND_EFFECT := "sound_effect"
const COMMAND_VOICE := "voice"
const COMMAND_UPDATE := "update"
const COMMAND_CLEAR := "clear"
const EFFECT_TRANSIT := "transit"
const EFFECT_APPEAR := "appear"
const EFFECT_DISAPPEAR := "disappear"
const EFFECT_SHAKE := "shake"
const EFFECT_JUMP := "jump"
const EFFECT_NOD := "nod"
const EFFECT_TILTLEFT := "tiltleft"
const EFFECT_TILTRIGHT := "tiltright"
const EFFECT_WAIT := "wait"
