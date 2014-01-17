package away3d.tools.serialize;

import away3d.animators.IAnimator;
import away3d.animators.data.JointPose;
import away3d.animators.data.Skeleton;
import away3d.animators.data.SkeletonJoint;
import away3d.animators.data.SkeletonPose;

import away3d.containers.ObjectContainer3D;
import away3d.containers.Scene3D;
import away3d.core.base.ISubGeometry;
import away3d.core.base.SkinnedSubGeometry;
import away3d.core.base.SubMesh;
import away3d.entities.Mesh;
import away3d.materials.MaterialBase;
import away3d.materials.lightpickers.StaticLightPicker;

class Serialize {

    static public var tabSize:Int = 2;

    public function new() {
    }

    static public function serializeScene(scene:Scene3D, serializer:SerializerBase):Void {
        var i:Int = 0;
        while (i < scene.numChildren) {
            serializeObjectContainer(scene.getChildAt(i), serializer);
            i++;
        }
    }

    static public function serializeObjectContainer(objectContainer3D:ObjectContainer3D, serializer:SerializerBase):Void {
        if (Std.is(objectContainer3D, Mesh)) serializeMesh(cast(objectContainer3D, Mesh), serializer)
        else serializeObjectContainerInternal(objectContainer3D, serializer, true);
    }

    static public function serializeMesh(mesh:Mesh, serializer:SerializerBase):Void {
        serializeObjectContainerInternal(cast(mesh, ObjectContainer3D), serializer, false);
        serializer.writeBoolean("castsShadows", mesh.castsShadows);
        if (mesh.animator) serializeAnimationState(mesh.animator, serializer);
        if (mesh.material) serializeMaterial(mesh.material, serializer);
        if (mesh.subMeshes.length) {
            for (subMesh in mesh.subMeshes)serializeSubMesh(subMesh, serializer);
        }
        serializeChildren(cast(mesh, ObjectContainer3D), serializer);
        serializer.endObject();
    }

    static public function serializeAnimationState(animator:IAnimator, serializer:SerializerBase):Void {
        serializer.beginObject(classNameFromInstance(animator), null);
        serializeAnimator(animator, serializer);
        serializer.endObject();
    }

    static public function serializeAnimator(animator:IAnimator, serializer:SerializerBase):Void {
        serializer.beginObject(classNameFromInstance(animator), null);
        serializer.endObject();
    }

    static public function serializeSubMesh(subMesh:SubMesh, serializer:SerializerBase):Void {
        serializer.beginObject(classNameFromInstance(subMesh), null);
        if (subMesh.material) serializeMaterial(subMesh.material, serializer);
        if (subMesh.subGeometry) serializeSubGeometry(subMesh.subGeometry, serializer);
        serializer.endObject();
    }

    static public function serializeMaterial(material:MaterialBase, serializer:SerializerBase):Void {
        serializer.beginObject(classNameFromInstance(material), material.name);
        if (Std.is(material.lightPicker, StaticLightPicker)) serializer.writeString("lights", Std.string(cast((material.lightPicker), StaticLightPicker).lights));
        serializer.writeBoolean("mipmap", material.mipmap);
        serializer.writeBoolean("smooth", material.smooth);
        serializer.writeBoolean("repeat", material.repeat);
        serializer.writeBoolean("bothSides", material.bothSides);
        serializer.writeString("blendMode", material.blendMode);
        serializer.writeBoolean("requiresBlending", material.requiresBlending);
        serializer.writeUint("uniqueId", material.uniqueId);
        serializer.writeUint("numPasses", material.numPasses);
        serializer.endObject();
    }

    static public function serializeSubGeometry(subGeometry:ISubGeometry, serializer:SerializerBase):Void {
        serializer.beginObject(classNameFromInstance(subGeometry), null);
        serializer.writeUint("numTriangles", subGeometry.numTriangles);
        if (subGeometry.indexData) serializer.writeUint("numIndices", subGeometry.indexData.length);
        serializer.writeUint("numVertices", subGeometry.numVertices);
        if (subGeometry.UVData) serializer.writeUint("numUVs", subGeometry.UVData.length);
        var skinnedSubGeometry:SkinnedSubGeometry = cast(subGeometry, SkinnedSubGeometry);
        if (skinnedSubGeometry) {
            if (skinnedSubGeometry.jointWeightsData) serializer.writeUint("numJointWeights", skinnedSubGeometry.jointWeightsData.length);
            if (skinnedSubGeometry.jointIndexData) serializer.writeUint("numJointIndexes", skinnedSubGeometry.jointIndexData.length);
        }
        serializer.endObject();
    }

    static public function serializeSkeletonJoint(skeletonJoint:SkeletonJoint, serializer:SerializerBase):Void {
        serializer.beginObject(classNameFromInstance(skeletonJoint), skeletonJoint.name);
        serializer.writeInt("parentIndex", skeletonJoint.parentIndex);
        serializer.writeTransform("inverseBindPose", skeletonJoint.inverseBindPose);
        serializer.endObject();
    }

    static public function serializeSkeleton(skeleton:Skeleton, serializer:SerializerBase):Void {
        serializer.beginObject(classNameFromInstance(skeleton), skeleton.name);
        for (skeletonJoint in skeleton.joints)serializeSkeletonJoint(skeletonJoint, serializer);
        serializer.endObject();
    }

    static public function serializeJointPose(jointPose:JointPose, serializer:SerializerBase):Void {
        serializer.beginObject(classNameFromInstance(jointPose), jointPose.name);
        serializer.writeVector3D("translation", jointPose.translation);
        serializer.writeQuaternion("orientation", jointPose.orientation);
        serializer.endObject();
    }

    static public function serializeSkeletonPose(skeletonPose:SkeletonPose, serializer:SerializerBase):Void {
        serializer.beginObject(classNameFromInstance(skeletonPose), "");
        serializer.writeUint("numJointPoses", skeletonPose.numJointPoses);
        for (jointPose in skeletonPose.jointPoses)serializeJointPose(jointPose, serializer);
        serializer.endObject();
    }

// private stuff - shouldn't ever need to call externally

    static private function serializeChildren(parent:ObjectContainer3D, serializer:SerializerBase):Void {
        var i:Int = 0;
        while (i < parent.numChildren) {
            serializeObjectContainer(parent.getChildAt(i), serializer);
            i++;
        }
    }

    static private function classNameFromInstance(instance:Dynamic):String {
        return getQualifiedClassName(instance).split("::").pop();
    }

    static private function serializeObjectContainerInternal(objectContainer:ObjectContainer3D, serializer:SerializerBase, serializeChildrenAndEnd:Bool):Void {
        serializer.beginObject(classNameFromInstance(objectContainer), objectContainer.name);
        serializer.writeTransform("transform", objectContainer.transform.rawData);
        if (serializeChildrenAndEnd) {
            serializeChildren(objectContainer, serializer);
            serializer.endObject();
        }
    }

}

