.import QtQml 2.15 as QtQml

    class buttonProperties {
        constructor(json, type, optionSet){
            let data = this.loadJson(json)
            if(data[type] == undefined || data[type][optionSet] == undefined) {
                //loads in the default template
                for(let key in buttonPropTemplate[optionSet]){
                    this[key] = buttonPropTemplate[optionSet][key]
                }
            }
            else {
                for(let key in buttonPropTemplate[optionSet]){
                    if(data[type][optionSet][key] == undefined){
                        //adds entries if they don't exist
                        this[key] = buttonPropTemplate[optionSet][key]
                    }
                    else{
                        this[key] = data[type][optionSet][key]
                    }
                }
            }
            this['type'] = type
            this['optionSet'] = optionSet
        }
        save(json){
            console.log(json)
            let data = this.loadJson(json)
            if(data[this.type] == undefined) data[this.type] = new Object()
            data[this.type][this.optionSet] = this
            return JSON.stringify(data, this.replacer)
        }
        replacer(key, value){
            if(key=='type') return undefined
            if(key=='optionSet') return undefined
            else return value
        }
        loadJson(json){
            try{
                return JSON.parse(json);
            }
            catch(e) {
                return new Object()
            }
        }
    }

    var buttonPropTemplate = {
        version: 1,
        colorProps: {
            color: '#000000',
            tint: 0,
            enabled: false,
            autoH: false,
            autoS: false,
            autoL: false,
            autoT: false,
            method: 0
        },
        indicatorProps: {
            height: 0,
            heightPercent: 0,
            width: 0,
            widthPercent: 0,
            radius: 0,
            radiusPercent: 0,
            margins: {
                top: 0,
                left: 0,
                right: 0,
                bottom: 0
            },
            marginsPercent: {
                top: 0,
                left: 0,
                right: 0,
                bottom: 0
            },
            aniDuration: 0,
            location: 0,
            align: 0,
            fill: false,
            unit: 0,
        }
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

function capitalizeFirstLetter(string) {
    return string.charAt(0).toUpperCase() + string.slice(1);
}