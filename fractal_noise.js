
var fractal_noise = (function () {
    function Noise2d(noise2d) {
        this.calculate = function (x, y,
            f = 1, l = 2, p = 0.5, o = 16
        ) {
            var n = 0
            var a = 1
            for (var i = 0; i < o; i++) {
                n += noise2d.calculate(x * f, y * f) * a;
                f *= l;
                a *= p;
            }
            return Math.max(-1, Math.min(n, 1));
        }
    }
    
    return { Noise2d: Noise2d };
}());

