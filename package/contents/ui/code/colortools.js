.import QtQml 2.15 as QtQml

    class buttonProperties {
        constructor(json, type){
            let data = JSON.parse(json);
            if(data[type] == undefined) {
                for(let key in buttonPropTemplate){
                    this[key] = buttonPropTemplate[key]
                }
            }
            else {
                for(let key in buttonPropTemplate){
                    if(data[type][key] == undefined){
                        //adds entries if they don't exist
                        this[key] = buttonPropTemplate[key]
                    }
                    else{
                        this[key] = data[type][key]
                    }
                }
            }
            this['type'] = type
        }
        save(json){
            let data = JSON.parse(json)
            data[this.type] = this
            return JSON.stringify(data, this.replacer)
        }
        replacer(key, value){
            if(key=='type') return undefined
            else return value
        }
    }

    var buttonPropTemplate = {
        color: '#000000',
        tint: 0,
        enabled: false,
        autoH: false,
        autoS: false,
        autoL: false,
        autoT: false,
        method: 0,
        AnimationDuration: 0,
        Location: 0,
        Alignment: 0,
        fill: 0,
        Units: 0,
        Height: 0,
        Width: 0,
        Radius: 0,
        margins: [0, 0, 0, 0]
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

