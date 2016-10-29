var SIZE = 720;

var renderer = PIXI.autoDetectRenderer(SIZE, SIZE);
var stage = new PIXI.Container();
var graphics = new PIXI.Graphics();
document.body.appendChild(renderer.view);
stage.addChild(graphics);

function fade(t) {
    return t * t * t * (t * (t * 6 - 15) + 10);
}

var lerp = function (a, b, t) {
    return a + (b - a) * t;
}


function init() {
    var noise = new fractal_noise.Noise2d(new perlin.Noise2d());
    var points = {}
    for (var x = 0; x < SIZE; x++) {
        points[x] = {};
        for (var y = 0; y < SIZE; y++) {
            var h = noise.calculate(x/(SIZE/4), y/(SIZE/4));
            points[x][y] = (Math.max(-1, Math.min(h, 1)) + 1) / 2
        }
    }

    var noise2 = new fractal_noise.Noise2d(new perlin.Noise2d());
    var clouds = {}
    for (var x = 0; x < SIZE; x++) {
        clouds[x] = {};
        for (var y = 0; y < SIZE; y++) {
            var h = noise2.calculate(x/(SIZE/2), y/(SIZE/2));
            clouds[x][y] = (Math.max(-1, Math.min(h, 1)) + 1) / 2
        }
    }


    draw(points, clouds);
    renderer.render(stage);
}

function calc_t(x, y, h) {
    var d = Math.abs((SIZE/2) - y) / (SIZE/2)
    d = 1 - fade(d)
    return (d + (1-h)) / 2
}


function draw(points, clouds) {
    graphics.lineStyle(0);
    for (var x = 0; x < SIZE; x++) {
        for (var y = 0; y < SIZE; y++) {
            draw_point(x, y, points[x][y], clouds[x][y]);
        }
    }
}

function draw_point(x, y, h, cloud) {
    var color = [0, 0, 0];
    if (0.50 < h) {
        var t = calc_t(x, y, h);
        if (0.8 < h) {
            color = [255/255, 255/255, 255/255];
        } else if (0.75 < h) {
            if (0.25 < t) {
                color = [147/255, 161/255, 161/255];
            } else {
                color = [255/255, 255/255, 255/255];
            }
        } else if (0.7 < h) {
            if (0.25 < t) {
                color = [42/255, 161/255, 152/255];
            } else {
                color = [255/255, 255/255, 255/255];
            }
        } else if (0.65 < h) {
            if (0.35 < t) {
                color = [133/255, 153/255, 0/255];
            } else if (0.25 < t) {
                color = [42/255, 161/255, 152/255];
            } else {
                color = [255/255, 255/255, 255/255];
            }
        } else if (0.6 < h) {
            if (0.25 < t) {
                color = [133/255, 153/255, 0/255];
            } else {
                color = [147/255, 161/255, 161/255];
            }
        } else if (0.55 < h) {
            if (0.25 < t) {
                color = [133/255, 153/255, 0/255];
            } else {
                color = [147/255, 161/255, 161/255];
            }
        } else {
            if (0.25 < t) {
                color = [238/255, 232/255, 213/255];
            } else {
                color = [253/255, 246/255, 227/255];
            }
        }
    } else {
        color = [38/255, 139/255, 210/255];
    }

    //cloud = fade(cloud);
    cloud = (Math.max(cloud - 0.5, 0)) * 2
    var r = lerp(color[0], 255/255, cloud);
    var g = lerp(color[1], 255/255, cloud);
    var b = lerp(color[2], 255/255, cloud);
    color = [r, g, b];

    graphics.beginFill(PIXI.utils.rgb2hex(color));
    graphics.drawRect(x, y, 1, 1);
}

init();

