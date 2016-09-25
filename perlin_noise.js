
GRID_SIZE = 256
SIZE = 720

var renderer = PIXI.autoDetectRenderer(SIZE, SIZE);
var stage = new PIXI.Container();
var graphics = new PIXI.Graphics();
document.body.appendChild(renderer.view);
stage.addChild(graphics);

function init() {
    var points = _.map(
        _.range(SIZE),
        function (x) {
            return _.map(_.range(SIZE),
                function (y) {
                    return noise(x/72, y/72);
                }
            );
        }
    );
    console.log("generated");
    console.log(points[10][10]);
    draw(points);
    renderer.render(stage);
}

function draw(points) {
    graphics.lineStyle(0);
    var xl = points.length;
    for (var x = 0; x < xl; x++) {
        var yl = points[x].length;
        for (var y = 0; y < yl; y++) {
            var h = points[x][y];
            h = (h + 1) / 2;
            var color = [h, h, h];
            var hex = PIXI.utils.rgb2hex(color);
            graphics.beginFill(hex);
            graphics.drawRect(x, y, 1, 1);
        }
    }
    graphics.beginFill(0xFFFFFF);
    graphics.lineStyle(0);
    var l = points.length;
    for (var i = 0; i < l; i++) {
        graphics.drawRect(i, points[i], 1, 720 - points[i]);
    }
}

//  returns a gradient vector (a random unit vector)
function grad_vec() {
    var theta = Math.random() * 2 * Math.PI;
    var x = Math.cos(theta);
    var y = Math.sin(theta);
    return { x: x, y: y };
}

//  calculates dot product of distance and gradient vectors
function grad(ix, iy, x, y) {
     var dx = x - ix;
     var dy = y - iy;
     return (dx * gradient[ix][iy].x + dy * gradient[ix][iy].y);
}

function fade(t) {
    return t * t * t * (t * (t * 6 - 15) + 10);
}

//  calculates perlin noise
function noise(x, y) {
    x = x % GRID_SIZE;
    y = y % GRID_SIZE;
    var ix0 = Math.floor(x);
    var ix1 = ix0 + 1;
    var iy0 = Math.floor(y);
    var iy1 = iy0 + 1;
    var fx = fade(x - ix0);
    var fy = fade(y - iy0);
    var n00 = grad(ix0, iy0, x, y);
    var n01 = grad(ix0, iy1, x, y);
    var n10 = grad(ix1, iy0, x, y);
    var n11 = grad(ix1, iy1, x, y);
    var n0  = lerp(n00, n01, fy);
    var n1  = lerp(n10, n11, fy);
    var n   = lerp(n0, n1, fx);
    return n
}

//  linear interpolation
function lerp(a, b, t) {
    return a + (b - a) * t
}

//  init 2d list of gradient vectors
var gradient = _.map(
    _.range(GRID_SIZE + 1),
    function () { return _.map(_.range(GRID_SIZE + 1), grad_vec) }
);

init();

