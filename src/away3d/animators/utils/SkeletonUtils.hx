package away3d.animators.utils;


import flash.geom.Orientation3D;
import flash.geom.Vector3D;
import flash.Vector;
import flash.geom.Matrix3D;
import away3d.animators.data.JointPose;
import flash.errors.Error;
import away3d.animators.data.SkeletonPose;
import away3d.animators.nodes.SkeletonClipNode;

class SkeletonUtils {

    static public function generateDifferenceClip(source:SkeletonClipNode, referencePose:SkeletonPose):SkeletonClipNode {
        var diff:SkeletonClipNode = new SkeletonClipNode();
        var numFrames:Int = source.frames.length;
        var i:Int = 0;
        while (i < numFrames) {
            diff.addFrame(generateDifferencePose(source.frames[i], referencePose), source.durations[i]);
            ++i;
        }
        return diff;
    }

    static public function generateDifferencePose(source:SkeletonPose, reference:SkeletonPose):SkeletonPose {
        if (source.numJointPoses != reference.numJointPoses) throw new Error("joint counts don't match!");
        var numJoints:Int = source.numJointPoses;
        var diff:SkeletonPose = new SkeletonPose();
        var srcPose:JointPose;
        var refPose:JointPose;
        var diffPose:JointPose;
        var mtx:Matrix3D = new Matrix3D();
        var tempMtx:Matrix3D = new Matrix3D();
        var vec:Vector<Vector3D>;
        var i:Int = 0;
        while (i < numJoints) {
            srcPose = source.jointPoses[i];
            refPose = reference.jointPoses[i];
            diffPose = new JointPose();
            diff.jointPoses[i] = diffPose;
            diffPose.name = srcPose.name;
            refPose.toMatrix3D(mtx);
            mtx.invert();
            mtx.append(srcPose.toMatrix3D(tempMtx));
            vec = mtx.decompose(Orientation3D.QUATERNION);
            diffPose.translation.copyFrom(vec[0]);
            diffPose.orientation.x = vec[1].x;
            diffPose.orientation.y = vec[1].y;
            diffPose.orientation.z = vec[1].z;
            diffPose.orientation.w = vec[1].w;
            ++i;
        }
        return diff;
    }

}

