"""Illustrative sign check for Proposition 3; these are not calibrated values."""
share, lam, sigma, eps = 0.6, 1.0, 1.0, 1.0
displacement = (1 - share) * lam / (sigma + eps)
assert displacement == 0.2
for gain in (0.05, 0.20, 0.35):
    response = round(gain - displacement, 2)
    print(f"gain={gain:.2f}, displacement={displacement:.2f}, wage response={response:+.2f}")
