
var SIZE = 1280
var H = 0.5;
var BASE_INTERVAL = 1

// console.log(PIXI);

var renderer = PIXI.autoDetectRenderer(1280, 720);
var stage = new PIXI.Container();
var graphics = new PIXI.Graphics();

document.body.appendChild(renderer.view);

stage.addChild(graphics);


function init() {
    var points = _.map(_.range(SIZE), function () { return 360; });
    displace_rec(points, 0, SIZE - 1, 360);
    draw(points);
    renderer.render(stage);
}

function displace_rec(points, ax, bx, max) {
    if (bx - ax > BASE_INTERVAL) {
        displace(points, ax, bx, max);
        var cx = Math.floor((ax + bx) / 2);
        displace_rec(points, ax, cx, max * H);
        displace_rec(points, cx, bx, max * H);
    }
}

function displace(points, ax, bx, max) {
    var ay = points[ax];
    var by = points[bx];

    var cx = Math.floor((ax + bx) / 2);
    var cy = Math.floor((ay + by) / 2);
    cy += Math.floor(Math.random() * (max * 2) - max);
    
    var dist = cx - ax
    for (var i = 0; i < dist; i++) {
        points[ax + i] = lerp(ay, cy, i / dist);
    }
    var dist = bx - cx;
    for (var i = 0; i < dist; i++) {
        points[cx + i] = lerp(cy, by, i / dist);
    }
}

function lerp(a, b, t) {
    return a + (b - a) * t;
}

function draw(points) {
    graphics.beginFill(0xFFFFFF);
    graphics.lineStyle(0);
    var l = points.length;
    for (var i = 1; i < l; i++) {
        graphics.drawRect(i, points[i], 1, 720 - points[i]);
    }
}

init();

