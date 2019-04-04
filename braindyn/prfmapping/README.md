# pRF mapping

STEPS:
1. File convertion to the BIDS format
2. **convert_movie_to_dm.py** - construction of 3D stimulus design matrix (time * x * y): MP4 movie of one run (8 bar passes). It is translated into 1 and 0.
3. **prepost.py** - high-pass filtering to remove slow drifts, % change within a run, median average over runs.
4. **fit.ipynb**	- fitting 4 parameter (polar angle, R square, eccentricity, size) pRFs. 
5. **prf_fit.py** - there can be several pRF models: Gaussian, Gaussian model with inhibitory surround, compressive spatial summation (Gaussian raised by a square, i.e. more plateau shaped Gaussian). We stick to the basic one, i.e. Gaussian.



