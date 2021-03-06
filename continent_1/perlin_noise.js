
var perlin = (function () {
    var GRID_SIZE = 4;

    var vec = function () {
        var theta = Math.random() * 2 * Math.PI;
        var x = Math.cos(theta);
        var y = Math.sin(theta);
        return { x: x, y: y };
    }

    var fade = function (t) {
        return t * t * t * (t * (t * 6 - 15) + 10);
    }

    var lerp = function (a, b, t) {
        return a + (b - a) * t;
    }

    function Noise2d() {
        var gradients = {};
        for (var i = 0; i < GRID_SIZE; i++) {
            gradients[i] = {};
            for (var j = 0; j < GRID_SIZE; j++) {
                gradients[i][j] = vec();
            }
        }

        var dot = function (cx, cy, x, y) {
            var dx = x - cx;
            var dy = y - cy;
            var gradient = gradients[cx % GRID_SIZE][cy % GRID_SIZE]
            return (dx * gradient.x + dy * gradient.y)
        }

        this.calculate = function (x, y) {
            x = x % GRID_SIZE;
            y = y % GRID_SIZE;

            var x0 = Math.floor(x);
            var y0 = Math.floor(y);
            var x1 = x0 + 1;
            var y1 = y0 + 1;

            var n00 = dot(x0, y0, x, y);
            var n01 = dot(x0, y1, x, y);
            var n10 = dot(x1, y0, x, y);
            var n11 = dot(x1, y1, x, y);

            var fade_x = fade(x - x0);
            var fade_y = fade(y - y0);
            var n0 = lerp(n00, n01, fade_y);
            var n1 = lerp(n10, n11, fade_y);
            var n = lerp(n0, n1, fade_x);
            return n;
        }

    }

    return { Noise2d: Noise2d }
}());

