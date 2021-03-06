###*
  @class core.obj
    オブジェクトを操作します。
###
core_array = require("./array")

#==============================================================================
# method
#==============================================================================
###*
  @method setMapVal
  オブジェクトの構造を指定して一度に値を設定します。
  @param {Object} target 初期化する連想配列
  @param {Array} mapList 構造を記述したマップ配列
  @param {Object} values 設定する値のセット
###
exports.setMapVal = (target, mapList, values) ->
  init = (target, map) =>
    for key in map
      if !@check(target[key])
        target[key] = {}
        
  setChildMapVal = (target, mapList, values) =>
    childMapList = core_array.getPopClone(mapList)
    for key in mapList[0]
      @setMapVal(target[key], childMapList, values)
      
  setInitVal = (target, values) =>
    for key, val of values
      if @check(val)
        target[key] = {}
        setInitVal(target[key], val)
      else
        target[key] = val
        
  if mapList.length > 0
    init(target, mapList[0])
    setChildMapVal(target, mapList, values)
  else
    setInitVal(target, values)

###*
  @method check
  Objectか判定します。
  @param {Object} obj 判定対象のデータ
  @return {boolean} 判定結果
###
exports.check = (obj) ->
  obj && typeof obj == "object" && !Array.isArray(obj)

###*
  @method clone
  オブジェクトのクローンを生成します。
  @param {Object} obj クローン元のデータ
  @return {Object} クローンデータ
###
exports.clone = (obj) ->
  f = ->
  f.prototype = obj
  return new f

###*
  @method deepClone
  オブジェクトのディープクローンを生成します。
  @param {Object} obj クローン元のデータ
  @return {Object} クローンデータ
###
exports.deepClone = (obj) ->
  object = $.extend(true, {}, obj)

###*
  @method selectArray
  オブジェクトの配列で指定した要素を選択して返します。
  @param {Object} obj オブジェクト
  @param {array} array 配列
  @return {Object} 配列で選択したオブジェクト
###
exports.selectArray = (obj, array) ->
  objTemp = obj
  for key in array
    objTemp = objTemp[key]
  objTemp

###*
  @method parallelLoop
  オブジェクトを配列の指定された数までの要素で検索し、検出されたオブジェクト全要素に大して残りの配列要素で検索をかける
  @param {Object} obj オブジェクト
  @param {Array} key_array キー配列
  @param {Number} parallelNum 検索の継ぎ目となる番号
  @param {Function} objList 検索された要素
###
exports.parallelLoop = (obj, key_array, parallelNum) =>
  objList = {}
  tempId = ""
  index_head = 0
  while index_head < parallelNum
    tempId += key_array[index_head] + "-"
    obj = obj[key_array[index_head]]
    index_head++

  for key, param of obj
    index_tail = index_head + 1
    tempId2 = ""

    while index_tail < key_array.length
      param = param[key_array[index_tail]]
      tempId2 += "-" + key_array[index_tail]
      index_tail++
    objList[tempId + key + tempId2] = param
  objList

###*
  @method marge
  オブジェクトを対象のオブジェクトに上書きでマージする
  @param {Object} target 対象のオブジェクト
  @param {Object} obj 上書きするオブジェクト
  @return {Object} マージしたオブジェクト
###
exports.marge = (target, obj) ->
  for key, param of obj
    if target[key] == undefined
      target[key] ={}
    if @check(param)
      @marge(target[key], param)
    else
      target[key] = param

###*
  @method keySeekAlg
  オブジェクト内の指定したkeyを持つオブジェクトに対して、callbackを実行します。
  @param {Object} obj 対象のオブジェクト
  @param {String} targetKey key
  @param {Object} callback callback(対象のオブジェクト)
###
exports.keySeekAlg = (obj, targetKey, callback) ->
  for key, param of obj
    if @check(param)
      @keySeekAlg(param, targetKey, callback)
    else
      if key == targetKey
        callback(obj)

###*
  @method allCall
  オブジェクトに存在する指定したkeyのメソッドをすべて呼び出します。
  @param {Object} obj 対象のオブジェクト
  @callback {Object} callback key:メソッドkey, arg:可変長引数
###
exports.allCall = (obj, callback) ->
  call = (target) ->
    target[callback.key] callback.arg...
  @keySeekAlg(obj, callback.key, call)

###*
  @method allDelete
  オブジェクトに存在する指定したkeyデータをすべて削除します。
  @param {Object} obj 対象のオブジェクト
  @param {String} key 削除データのkey
###
exports.allDelete = (obj, key) ->
  call = (target) ->
    delete target[key]
  @keySeekAlg(obj, key, call)
