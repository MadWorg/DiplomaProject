extends Node

var lives = 15
var treasure = 0
var totalTreasure = 0
var keys = 0
var mapPiece = false
var disableAnimate = false

func restart():
	lives = 3
	treasure = 0
	mapPiece = false

func newLevel():
	totalTreasure += treasure
	treasure = 0
