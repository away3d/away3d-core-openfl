/**
 * MethodVOSet provides a EffectMethodBase and MethodVO combination to be used by a material, allowing methods
 * to be shared across different materials while their internal state changes.
 */
package away3d.materials.methods;


class MethodVOSet {

/**
	 * An instance of a concrete EffectMethodBase subclass.
	 */
    public var method:EffectMethodBase;
/**
	 * The MethodVO data for the given method containing the material-specific data for a given material/method combination.
	 */
    public var data:MethodVO;
/**
	 * Creates a new MethodVOSet object.
	 * @param method The method for which we need to store a MethodVO object.
	 */

    public function new(method:EffectMethodBase) {
        this.method = method;
        data = method.createMethodVO();
    }

}

