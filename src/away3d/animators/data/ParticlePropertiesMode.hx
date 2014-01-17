/**
 * Options for setting the properties mode of a particle animation node.
 */
package away3d.animators.data;

class ParticlePropertiesMode {

/**
	 * Mode that defines the particle node as acting on global properties (ie. the properties set in the node constructor or the corresponding animation state).
	 */
    static public var GLOBAL:Int = 0;
/**
	 * Mode that defines the particle node as acting on local static properties (ie. the properties of particles set in the initialising function on the animation set).
	 */
    static public var LOCAL_STATIC:Int = 1;
/**
	 * Mode that defines the particle node as acting on local dynamic properties (ie. the properties of the particles set in the corresponding animation state).
	 */
    static public var LOCAL_DYNAMIC:Int = 2;
}

