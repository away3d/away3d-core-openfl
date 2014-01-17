package away3d.filters;

import away3d.filters.tasks.Filter3DHBlurTask;

class HBlurFilter3D extends Filter3DBase {
    public var amount(get_amount, set_amount):Int;
    public var stepSize(get_stepSize, set_stepSize):Int;

    private var _blurTask:Filter3DHBlurTask;
/**
	 * Creates a new HBlurFilter3D object
	 * @param amount The amount of blur in pixels
	 * @param stepSize The distance between two blur samples. Set to -1 to autodetect with acceptable quality (default value).
	 */

    public function new(amount:Int, stepSize:Int = -1) {
        super();
        _blurTask = new Filter3DHBlurTask(amount, stepSize);
        addTask(_blurTask);
    }

    public function get_amount():Int {
        return _blurTask.amount;
    }

    public function set_amount(value:Int):Int {
        _blurTask.amount = value;
        return value;
    }

/**
	 * The distance between two blur samples. Set to -1 to autodetect with acceptable quality (default value).
	 * Higher values provide better performance at the cost of reduces quality.
	 */

    public function get_stepSize():Int {
        return _blurTask.stepSize;
    }

    public function set_stepSize(value:Int):Int {
        _blurTask.stepSize = value;
        return value;
    }

}

