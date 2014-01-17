/**
 * ...
 */
package away3d.animators.states;

import away3d.animators.data.AnimationRegisterCache;
import away3d.animators.data.AnimationSubGeometry;
import away3d.animators.nodes.ParticleRotateToHeadingNode;
import away3d.animators.nodes.ParticleNodeBase;
import away3d.animators.ParticleAnimator;
import away3d.cameras.Camera3D;
import away3d.core.base.IRenderable;
import away3d.core.managers.Stage3DProxy;
import flash.geom.Matrix3D;


class ParticleRotateToHeadingState extends ParticleStateBase {

    private var _matrix:Matrix3D;

    public function new(animator:ParticleAnimator, particleNode:ParticleNodeBase) {
        _matrix = new Matrix3D();
        super(animator, particleNode);
    }

    override public function setRenderState(stage3DProxy:Stage3DProxy, renderable:IRenderable, animationSubGeometry:AnimationSubGeometry, animationRegisterCache:AnimationRegisterCache, camera:Camera3D):Void {
        if (animationRegisterCache.hasBillboard) {
            _matrix.copyFrom(renderable.sceneTransform);
            _matrix.append(camera.inverseSceneTransform);
            animationRegisterCache.setVertexConstFromMatrix(animationRegisterCache.getRegisterIndex(_animationNode, ParticleRotateToHeadingNode.MATRIX_INDEX), _matrix);
        }
    }

}

