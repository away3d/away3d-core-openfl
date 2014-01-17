/**
 * Contains transformation data for a skeleton joint, used for skeleton animation.
 *
 * @see away3d.animation.data.Skeleton
 * @see away3d.animation.data.SkeletonJoint
 *
 * todo: support (uniform) scale
 */
package away3d.animators.data;

import flash.geom.Matrix3D;
import flash.geom.Vector3D;
import away3d.core.math.Quaternion;
class JointPose {

/**
	 * The name of the joint to which the pose is associated
	 */
    public var name:String;
// intention is that this should be used only at load time, not in the main loop
/**
	 * The rotation of the pose stored as a quaternion
	 */
    public var orientation:Quaternion;
/**
	 * The translation of the pose
	 */
    public var translation:Vector3D;

    public function new() {
        orientation = new Quaternion();
        translation = new Vector3D();
    }

/**
	 * Converts the transformation to a Matrix3D representation.
	 *
	 * @param target An optional target matrix to store the transformation. If not provided, it will create a new instance.
	 * @return The transformation matrix of the pose.
	 */

    public function toMatrix3D(target:Matrix3D = null):Matrix3D {
        if (target == null)target = new Matrix3D();
        orientation.toMatrix3D(target);
        target.appendTranslation(translation.x, translation.y, translation.z);
        return target;
    }

/**
	 * Copies the transformation data from a source pose object into the existing pose object.
	 *
	 * @param pose The source pose to copy from.
	 */

    public function copyFrom(pose:JointPose):Void {
        var or:Quaternion = pose.orientation;
        var tr:Vector3D = pose.translation;
        orientation.x = or.x;
        orientation.y = or.y;
        orientation.z = or.z;
        orientation.w = or.w;
        translation.x = tr.x;
        translation.y = tr.y;
        translation.z = tr.z;
    }

}

