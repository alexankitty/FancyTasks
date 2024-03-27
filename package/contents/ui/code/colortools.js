.import QtQml 2.15 as QtQml

class buttonProperties {
    static getList() { return ['color', 'enabled', 'auto', 'method', 'tint']}
    static getAutoList() { return ['autoH', 'autoS', 'autoL', 'autoT']}
    static getNumberList() { return ['method']}
    static getTypes() { return ['Button', 'Indicator', 'IndicatorTail']}
    constructor(argsArr){
        let list = buttonProperties.getList()
        let autoList = buttonProperties.getAutoList()
        let numberList = buttonProperties.getNumberList()
        for(let x = 0; x < list.length; x++){
            if(list[x] == 'auto'){
                for(let y = 0; y < autoList.length; y++){
                    this[autoList[y]] = argsArr[x] & ( 1 << y) ? true : false
                }
                continue
            }
            for(let z = 0; z < numberList.length; z++){
                if(argsArr[x] == numberList[z]){
                    this[list[x]] = parseInt(argsArr[x])
                    continue
                }
            }
            this[list[x]] = argsArr[x]
        }
    }
}

function getButtonProperties(type, stringList){
    if(!stringList) return false
    let list = buttonProperties.getList();
    stringList = expandArray(stringList, list)
    let accessorModifer = getAccessModifier(type, list);
    if(accessorModifer === false) return;
    let result = [];
    for(let x = 0; x < list.length; x++){
        result.push(stringList[accessorModifer + x]);
    }
    return new buttonProperties(result);
}

function setButtonProperties(type, object, stringList){
    if(!stringList) return false;
    let list = buttonProperties.getList();
    let autoList = buttonProperties.getAutoList();
    let accessorModifer = getAccessModifier(type, list);
    if(!accessorModifer === false) return;
    stringList = expandArray(stringList, list)
    for(let x = 0; x < list.length; x++){
        if(list[x] == "auto"){
            let bits = 0
            for(let y = 0; y < autoList.length; y++){
                bits = bits | (object[autoList[y]] & 1) << y;
            }
            stringList[accessorModifer + x] = bits
            continue;
        }
        stringList[accessorModifer + x] = object[list[x]];
    }
    return stringList;
}

function expandArray(arr, list){
    let listSize = 0
    for(let x = 0; x < arr.length; x++){
        let startFound = false
        if(arr[x].startsWith("#")){
            if(startFound){
                listSize = x + 1
                break
            }
            startFound = true
        }
    }
    const propCount = arr.length / listSize
    const elementCount = arr.length / propCount

    if(propCount < list.length){
        let toAdd = list.length - propCount
        let arraySplatter = [... Array(toAdd)]
        for(let x = 1; x <= elementCount; x++){
            arr = [
                ...arr.slice(0, x * propCount),
                ...arraySplatter,
                ...arr.slice(x * propCount)
            ]
        }
    }
    return arr;
}

function getAccessModifier(type, list){
    if(typeof type == "number") return list.length * number
    //Minor optimization
    else{
        let types = buttonProperties.getTypes();
        for(let i = 0; i < types.length; i++){
            if(type == types[i]) return list.length * i
        }
    }  
    return false;
}

function mixColor(input, auto, autoBits){
    let staticColor = hexToHSL(input);
    let autoColor = hexToHSL(auto);
    let properties = ["h", "s", "l"]
    let destinationColor = [0,0,0,1]
    for(let x = 0; x < properties.length; x++){
        if(autoBits[properties[x]]) destinationColor[x] = autoColor[properties[x]]
        else destinationColor[x] = staticColor[properties[x]]
    }
    return Qt.hsla(... destinationColor)
}

function hexToHSL(hex) {
    if(hex.toString().length == 9) {
        var result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex);
        var a = parseInt(result[1], 16);
        var r = parseInt(result[2], 16);
        var g = parseInt(result[3], 16);
        var b = parseInt(result[4], 16);
    }
    else{
        var result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex);
        var r = parseInt(result[1], 16);
        var g = parseInt(result[2], 16);
        var b = parseInt(result[3], 16);
        var a = 255;
    }
    r /= 255, g /= 255, b /= 255, a /= 255;
    var max = Math.max(r, g, b), min = Math.min(r, g, b);
    var h, s, l = (max + min) / 2;
    if(max == min){
        h = s = 0; // achromatic
    }else{
        var d = max - min;
        s = l > 0.5 ? d / (2 - max - min) : d / (max + min);
        switch(max){
            case r: h = (g - b) / d + (g < b ? 6 : 0); break;
            case g: h = (b - r) / d + 2; break;
            case b: h = (r - g) / d + 4; break;
        }
        h /= 6;
    }
    var HSLA = new Object();
    HSLA['h']=h;
    HSLA['s']=s;
    HSLA['l']=l;
    HSLA['a']=a;
    return HSLA;
}

