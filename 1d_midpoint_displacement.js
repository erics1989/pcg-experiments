
var POINT1 = { x: 0, y: 360 }
var POINTN = { x: 1280, y: 360 }

// console.log(PIXI);

var renderer = PIXI.autoDetectRenderer(1280, 720);
var stage = new PIXI.Container();
var graphics = new PIXI.Graphics();

document.body.appendChild(renderer.view);

stage.addChild(graphics);


function init() {
    var points = _.map(_.range(1280), function () { return 360; });
    displace_rec(points, 0, 1279, 360);
    draw(points);
    renderer.render(stage);
}

function displace_rec(points, ax, bx, max) {
    if (bx - ax > 16) {
        displace(points, ax, bx, max);
        var cx = (ax + bx) / 2;
        displace_rec(points, ax, Math.floor(cx), max / 2);
        displace_rec(points, Math.ceil(cx), bx, max / 2);
    }
}

function displace(points, ax, bx, max) {
    var ay = points[ax];
    var by = points[bx];

    var cx = (ax + bx) / 2;

    var cy = Math.floor((ay + by) / 2);
    cy += Math.floor(Math.random() * (max * 2) - max);
    
    cx = Math.floor(cx);
    var dist = cx - ax
    for (var i = 0; i < dist; i++) {
        points[ax + i] = lerp(ay, cy, i / dist);
    }

    cx = Math.ceil(cx);
    var dist = bx - cx;
    for (var i = 0; i < dist; i++) {
        points[cx + i] = lerp(cy, by, i / dist);
    }
}

function lerp(a, b, t) {
    return a + (b - a) * t;
}

function draw(points) {
    graphics.lineStyle(2, 0x657b83);
    var l = points.length;
    for (var i = 1; i < l; i++) {
        graphics.moveTo(i, 720);
        graphics.lineTo(i, points[i]);
    }
}

init();

