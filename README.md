# ICSS

Matlab implementation of the [ICSS algorithm of Inclan and Tiao](http://www.jstor.org/stable/2290916) ("Use of cumulative sums of squares for retrospective detection of changes of variance").

## How does it work?

Load to the `matlab` directory and run `demo`, or `demo_accelermeter_data` for an application of x-axis value of a recorded activity series with a smartphone.

The result, for the paper provided data is:
![Paper data segmentation](/images/paper.png?raw=true "Paper segmentation")

For accelerometer data:
![Accelerometer data segmentation](/images/sit-walk-turn-walk-turn-walk-sit.png?raw=true "Accelerometer data segmentation")

For any vector of values, run `ICSS(data)` to obtain the change points.

## Available datasets

There are a couple of predefined datasets availble.
These can be generated using `data = ProvideDataBatch(size, type)`.
The types are:

  * alternating: Generate alternating variances of `1` and `5` with mean `0`
  * paper: use the dataset as defined in the paper (changepoints at `391` and `518`, with variances `1`, `0.365` and `1.033`)
  * homogeneous: homogeneous dataset with mean 0 and variance 1
  * single: create a single breakpoint at half or the data. Variance goes there from `1` to `2`.