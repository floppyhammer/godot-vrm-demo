class_name Algorithm

const PI2: float = 2.0 * PI
const INV_LOG10: float = 1.0 / log(10)

#####################
# Functions for FFT #
#####################

static func calc_rms(sample_array: Array[float]) -> float:
	var rms: float = 0.0
	
	for i in range(sample_array.size()):
		rms += sample_array[i] * sample_array[i]
	
	rms = sqrt(rms / sample_array.size())
	rms = 20 * (log(rms) * INV_LOG10)
	
	return rms

static func array_normalize(sample_array: Array[float]):
	var n: int = sample_array.size()
	
	var vmax: float = 0.0;
	var vmin: float = 0.0;
	
	for i in range(n):
		vmax = max(vmax, sample_array[i])
		vmin = min(vmin, sample_array[i])
	
	var diff: float = vmax - vmin
	var d: float = 1.0 / diff if diff != 0 else 1.0
	
	for i in range(n):
		sample_array[i] = (sample_array[i] - vmin) * d
	
	return

static func smoothing(sample_array: Array[float], before_sample_array: Array[float]):
	var n = sample_array.size();
	for i in range(n):
		sample_array[i] = (sample_array[i] + before_sample_array[i]) * 0.5
	return

static func hamming(sample_array: Array[float]):
	var n = sample_array.size();
	for i in range(n):
		var h = 0.54 - 0.46 * cos(PI2 * i / float(n - 1));
		sample_array[i] = sample_array[i] * h;
	sample_array[0] = 0
	sample_array[n - 1] = 0
	return;

static func rfft(sample_array: Array[float], reverse: bool = false, positive: bool = true):
	var n: int = sample_array.size()
	var cmp_array = []
	for i in range(n):
		cmp_array.append(Vector2(sample_array[i], 0.0))
	fft(cmp_array, reverse)
	if positive:
		for i in range(n):
			sample_array[i] = abs(cmp_array[i].x)
	else:
		for i in range(n):
			sample_array[i] = cmp_array[i].x
	if reverse:
		var inv_n: float = 1.0 / float(n)
		for i in range(n):
			sample_array[i] *= inv_n
	return

# Reference (https://caddi.tech/archives/836) 
static func fft(a: Array, reverse: bool):
	var N: int = a.size()
	if N == 1:
		return
	var b: Array = []
	var c: Array = []
	for i in range(N):
		if i % 2 == 0:
			b.append(a[i])
		elif i % 2 == 1:
			c.append(a[i])
	fft(b, reverse);
	fft(c, reverse);
	var circle: float = -PI2 if reverse else PI2
	for i in range(N):
		a[i] = b[i % (N / 2)] + ComplexCalc.cmlt(c[i % (N / 2)], ComplexCalc.cexp(Vector2(0, circle * float(i) / float(N))));
	return

static func lifter(sample_array: Array[float], level: int):
	var i_min: int = level
	var i_max: int = sample_array.size() - 1 - level
	for i in range(sample_array.size()):
		if i > i_min && i <= i_max:
			sample_array[i] = 0.0
	return

static func filter(sample_array: Array[float], lowcut: int, highcut: int):
	var minimum = sample_array[0]
	for i in range(sample_array.size()):
		minimum = min(minimum, sample_array[i])
	
	# Avoid log(0)
	if minimum == 0.0:
		minimum == 0.000001
		
	for i in range(sample_array.size()):
		if i <= lowcut || i >= highcut:
			sample_array[i] = minimum
