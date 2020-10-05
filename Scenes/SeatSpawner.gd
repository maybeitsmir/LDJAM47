extends Node2D
onready var loader = get_node("/root/Loader")
const Particle = preload("res://Scenes/DeathExplosion.tscn")
onready var tweenIn = $TweenToSeat
onready var tweenOut = $TweenToDoor
var drinkWanted = decideDrink()
var sprites = []
var voicelines = []
var spawnTime = 5
var angerTime = 15
#decide sprite
#decide drink
#have a random amount of time pass, seat empty
#spawn in enemy and tween to seat
#wait, then have enemy request their drink
#if correct, have enemy be happy, wait, then leave, tweening back to door
#if incorrect or time expires, have enemy become upset and die
	
func _ready():
	resetEnemy()

func resetEnemy():
	randomize()
	decideSprite()
	#decideDrink()
	decideSpawnTime()
	$SpawnTimer.start(spawnTime)
func _on_SpawnTimer_timeout():
	moveToSeat()
func _on_TweenToSeat_tween_all_completed():
	yield(get_tree().create_timer(1),"timeout")
	decideAngerTime()
	askForDrink()

	
func decideSprite(): #decides the enemy's sprite. normal during normal hours, scary during scarytime
	randomize()
	sprites.clear()
	var path = "lol"
	if loader.isScaryTimeActive == 0:
		path = "res://Sprites/NormalEnemies"
	if loader.isScaryTimeActive == 1:
		path = "res://Sprites/Enemies"
	var dir = Directory.new()
	dir.open(path)
	dir.list_dir_begin()
	while true :
		var file_name = dir.get_next()
		if file_name == "":
			break
		elif !file_name.begins_with(".") and !file_name.ends_with(".import"):
			sprites.append(load(path + "/" + file_name))
	dir.list_dir_end()
	sprites.shuffle()
	var sprite = sprites[0]
	$Enemy/Sprite.texture = sprite

func decideDrink():
	randomize()
	drinkWanted = int(randi()%17+1)
	while drinkWanted > 4 and drinkWanted < 10:
		drinkWanted = int(randi()%17+1)
	print("E",drinkWanted)
	return drinkWanted
	
func decideSpawnTime():
	var spawnTime = 5
	spawnTime = rand_range(5, 10) - (0.2 * loader.currentDifficulty) 
	if spawnTime <= 0.1:
		spawnTime = 0.1
	print("Time before spawn is" + str(spawnTime) + " seconds!")
	
	
func decideAngerTime():
	var angerTime = 15
	angerTime = 15 - (0.4 * loader.currentDifficulty)
	if angerTime <= 3:
		angerTime = 3
	print("Customer patience is" + str(angerTime) + " seconds!")
	
func moveToSeat():
	$Enemy.visible = true
	print("Enemy should now be visible...")
	tweenIn.interpolate_property($Enemy,"global_position",Vector2($Door.global_position.x, $Door.global_position.y),Vector2($Seat.global_position.x,$Seat.global_position.y),1,Tween.TRANS_LINEAR)
	tweenIn.start()

func askForDrink():
	$Enemy/Sprite.frame = 1
	$Enemy/Hitbox.disabled = false
	$Enemy/BubbleSprite.visible = true
	$Enemy/WantSprite.frame = drinkWanted
	$Enemy/WantSprite.visible = true
	$AngerTimer.paused = false
	$AngerTimer.start(angerTime)
	
func _on_Enemy_DrinkGot(): #when the enemy gets the proper drink. GJ!
	$Enemy/BubbleSprite.visible = false
	$Enemy/WantSprite.visible = false
	$Enemy/Hitbox.disabled = true
	$Enemy/Sprite.frame = 2
	bartenderTalk()
	loader.add_score(1)
	yield(get_tree().create_timer(2),"timeout")
	if loader.isScaryTimeActive == 0:
		$NormalGood.play()
	$Enemy/Sprite.frame = 4
	$AngerTimer.paused = true
	tweenOut.interpolate_property($Enemy,"global_position",Vector2($Seat.global_position.x, $Seat.global_position.y),Vector2($Door.global_position.x,$Door.global_position.y),1,Tween.TRANS_LINEAR)
	tweenOut.start()
	yield(get_tree().create_timer(1),"timeout")
	resetEnemyState()
	
func _on_Enemy_Death(): #when the enemy gets the wrong drink. moron.....
	$Enemy/Hitbox.disabled = true
	$Enemy/Sprite.frame = 3
	$Enemy/BubbleSprite.visible = false
	$Enemy/WantSprite.visible = false
	yield(get_tree().create_timer(1),"timeout")
	if loader.isScaryTimeActive == 1:
		loader.made_mistake(1)
		var particle = Particle.instance()
		var main = get_tree().current_scene
		main.add_child(particle)
		particle.global_position = $Enemy.global_position
	else:
		$Enemy/Sprite.frame = 4
		$NormalMistake.play()
		tweenOut.interpolate_property($Enemy,"global_position",Vector2($Seat.global_position.x, $Seat.global_position.y),Vector2($Door.global_position.x,$Door.global_position.y),1,Tween.TRANS_LINEAR)
		tweenOut.start()
		yield(get_tree().create_timer(1),"timeout")
	resetEnemyState()
	
func _on_AngerTimer_timeout(): #if the customer gets angry they explode
	$Enemy/Hitbox.disabled = true
	$Enemy/Sprite.frame = 3
	$Enemy/BubbleSprite.visible = false
	$Enemy/WantSprite.visible = false
	yield(get_tree().create_timer(1),"timeout")
	if loader.isScaryTimeActive == 0:
		$Enemy/Sprite.frame = 4
		$NormalMistake.play()
		tweenOut.interpolate_property($Enemy,"global_position",Vector2($Seat.global_position.x, $Seat.global_position.y),Vector2($Door.global_position.x,$Door.global_position.y),1,Tween.TRANS_LINEAR)
		tweenOut.start()
		yield(get_tree().create_timer(1),"timeout")
	if loader.isScaryTimeActive == 1:
		loader.made_mistake(1)
		var particle = Particle.instance()
		var main = get_tree().current_scene
		main.add_child(particle)
		particle.global_position = position
		yield(get_tree().create_timer(1),"timeout")
	resetEnemyState()
	
func bartenderTalk():
	if int(randi()%10) == 1:
		randomize()
		var soundpath = "lol"
		soundpath = "res://Sounds/Bartender"
		var sounddir = Directory.new()
		sounddir.open(soundpath)
		sounddir.list_dir_begin()
		while true :
			var file_name = sounddir.get_next()
			if file_name == "":
				break
			elif !file_name.begins_with(".") and !file_name.ends_with(".import"):
				voicelines.append(load(soundpath + "/" + file_name))
		sounddir.list_dir_end()
		voicelines.shuffle()
		var voiceline = voicelines[0]
		$BartenderTalk.stream = voiceline
		$BartenderTalk.play()
		
	
func resetEnemyState(): #resets enemy, giving the illusion of despawning them
	$Enemy.visible = false
	$Enemy/Hitbox.disabled = true
	$Enemy/BubbleSprite.visible = false
	$Enemy/WantSprite.visible = false
	$Enemy/Sprite.frame = 0
	decideDrink()
	resetEnemy()