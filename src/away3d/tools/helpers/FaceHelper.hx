/**
 * Helper Class for face manipulation<code>FaceHelper</code>
 */
package away3d.tools.helpers;


import flash.errors.Error;
import flash.Vector;
import away3d.core.base.ISubGeometry;
import away3d.core.base.SubGeometry;
import away3d.core.base.CompactSubGeometry;
import away3d.core.base.data.UV;
import away3d.core.base.data.Vertex;
import away3d.entities.Mesh;

class FaceHelper {

    static private var LIMIT:Int = 196605;
    static private var SPLIT:Int = 2;
    static private var TRI:Int = 3;
    static private var QUARTER:Int = 4;
    static private var _n:Vertex = new Vertex();
    static private var _t:Vertex = new Vertex();
/*Adding a face*/

    static public function addFace(mesh:Mesh, v0:Vertex, v1:Vertex, v2:Vertex, uv0:UV, uv1:UV, uv2:UV, subGeomIndice:Int):Void {
        var subGeom:SubGeometry;
        if (mesh.geometry.subGeometries.length == 0) {
            subGeom = new SubGeometry();
            mesh.geometry.addSubGeometry(subGeom);
        }

        else {
            if (Std.is(mesh.geometry.subGeometries[0], CompactSubGeometry)) mesh.geometry.convertToSeparateBuffers();
        }

        if (mesh.geometry.subGeometries.length - 1 < subGeomIndice) throw new Error("no subGeometry at index provided:" + subGeomIndice);
        subGeom = cast((mesh.geometry.subGeometries[subGeomIndice]), SubGeometry);
        var vertices:Vector<Float> = subGeom.vertexData || new Vector<Float>();
        var normals:Vector<Float> = subGeom.vertexNormalData || new Vector<Float>();
        var tangents:Vector<Float> = subGeom.vertexTangentData || new Vector<Float>();
        var indices:Vector<UInt>;
        var uvs:Vector<Float>;
        var lengthVertices:Int = vertices.length;
        _n = getFaceNormal(v0, v1, v2, _n);
        _t = getFaceTangent(v0, v1, v2, uv0.v, uv1.v, uv2.v, 1, _t);
        if (lengthVertices + 9 > LIMIT) {
            indices = Vector.ofArray(cast [0, 1, 2]);
            vertices = Vector.ofArray(cast [v0.x, v0.y, v0.z, v1.x, v1.y, v1.z, v2.x, v2.y, v2.z]);
            uvs = Vector.ofArray(cast [uv0.u, uv0.v, uv1.u, uv1.v, uv2.u, uv2.v]);
            normals = Vector.ofArray(cast [_n.x, _n.y, _n.z, _n.x, _n.y, _n.z, _n.x, _n.y, _n.z]);
            tangents = Vector.ofArray(cast [_t.x, _t.y, _t.z, _t.x, _t.y, _t.z, _t.x, _t.y, _t.z]);
            subGeom = new SubGeometry();
            mesh.geometry.addSubGeometry(subGeom);
        }

        else {
            indices = subGeom.indexData || new Vector<UInt>();
            uvs = subGeom.UVData || new Vector<Float>();
            vertices.fixed = indices.fixed = uvs.fixed = false;
            var ind:Int = lengthVertices / 3;
            var nind:Int = indices.length;
            indices[nind++] = ind++;
            indices[nind++] = ind++;
            indices[nind++] = ind++;
            vertices.push(v0.x, v0.y, v0.z, v1.x, v1.y, v1.z, v2.x, v2.y, v2.z);
            uvs.push(uv0.u, uv0.v, uv1.u, uv1.v, uv2.u, uv2.v);
            normals.push(_n.x, _n.y, _n.z, _n.x, _n.y, _n.z, _n.x, _n.y, _n.z);
            tangents.push(_t.x, _t.y, _t.z, _t.x, _t.y, _t.z, _t.x, _t.y, _t.z);
        }

        updateSubGeometryData(subGeom, vertices, indices, uvs, normals, tangents);
    }

/**
	 * Remove a face from a mesh
	 * @param mesh                        Mesh. The mesh to remove a face from
	 * @param index                        uint. Index of the face in vertices. The value represents the position in indices vector divided by 3.
	 * For instance, to edit face [1], the parameter indice will be 1. The x value of the v0 at position 3 in vertice vector is then extracted from vertices[indices[indice]]
	 * @param subGeomIndice        uint. Index of vertex 1 of the face
	 */

    static public function removeFace(mesh:Mesh, index:Int, subGeomIndice:Int):Void {
        var pointer:Int = index * 3;
        var subGeom:SubGeometry = getSubGeometry(mesh, subGeomIndice);
        var indices:Vector<UInt> = subGeom.indexData.concat();
        if (pointer > indices.length - 3) throw new Error("ERROR >> face index out of range! Use the location in indice vector /3. For example, pass 1 if you want edit face 1, not 3!");
        var vertices:Vector<Float> = subGeom.vertexData.concat();
        var normals:Vector<Float> = subGeom.vertexNormalData.concat();
        var tangents:Vector<Float> = subGeom.vertexTangentData.concat();
        var uvs:Vector<Float> = subGeom.UVData.concat();
        var pointerEnd:Int = pointer + 2;
        var oInd:Int;
        var oVInd:Int;
        var oUVInd:Int;
        var indInd:Int;
        var uvInd:Int;
        var vInd:Int;
        var i:Int = 0;
        var nvertices:Vector<Float> = new Vector<Float>();
        var nnormals:Vector<Float> = new Vector<Float>();
        var ntangents:Vector<Float> = new Vector<Float>();
        var nindices:Vector<UInt> = new Vector<UInt>();
        var nuvs:Vector<Float> = new Vector<Float>();
//Check for shared vectors
        if (vertices.length / 3 != indices.length) {
            var sharedIndice:Int;
            i = 0;
            while (i < indices.length) {
                if (i >= pointer && i <= pointerEnd) {
                    ++i;
                    continue;
                }
                ;
                oInd = indices[i];
                oVInd = oInd * 3;
                oUVInd = oInd * 2;
                sharedIndice = getUsedIndice(nvertices, vertices[oVInd], vertices[oVInd + 1], vertices[oVInd + 2]);
                if (sharedIndice != -1) {
                    nindices[indInd++] = sharedIndice;
                    {
                        ++i;
                        continue;
                    }

                }
                nindices[indInd++] = nvertices.length / 3;
                nvertices[vInd] = vertices[oVInd];
                nnormals[vInd] = normals[oVInd];
                ntangents[vInd] = tangents[oVInd];
                vInd++;
                oVInd++;
                nvertices[vInd] = vertices[oVInd];
                nnormals[vInd] = normals[oVInd];
                ntangents[vInd] = tangents[oVInd];
                vInd++;
                oVInd++;
                nvertices[vInd] = vertices[oVInd];
                nnormals[vInd] = normals[oVInd];
                ntangents[vInd] = tangents[oVInd];
                vInd++;
                nuvs[uvInd++] = uvs[oUVInd];
                nuvs[uvInd++] = uvs[oUVInd + 1];
                ++i;
            }
        }

        else {
            i = 0;
            while (i < indices.length) {
                if (i < pointer || i > pointerEnd) {
                    oInd = indices[i];
                    oVInd = oInd * 3;
                    oUVInd = oInd * 2;
                    nindices[indInd++] = vInd / 3;
                    nvertices[vInd] = vertices[oVInd];
                    nnormals[vInd] = normals[oVInd];
                    ntangents[vInd] = tangents[oVInd];
                    vInd++;
                    oVInd++;
                    nvertices[vInd] = vertices[oVInd];
                    nnormals[vInd] = normals[oVInd];
                    ntangents[vInd] = tangents[oVInd];
                    vInd++;
                    oVInd++;
                    nvertices[vInd] = vertices[oVInd];
                    nnormals[vInd] = normals[oVInd];
                    ntangents[vInd] = tangents[oVInd];
                    vInd++;
                    nuvs[uvInd++] = uvs[oUVInd];
                    nuvs[uvInd++] = uvs[oUVInd + 1];
                }
                ++i;
            }
        }

        updateSubGeometryData(subGeom, nvertices, nindices, nuvs, nnormals, ntangents);
    }

/**
	 * Remove a series of faces from a mesh. Indices and geomIndices must have the same length.
	 * Meshes with less that 20k faces and single material, will generally only have one single subgeometry.
	 * The geomIndices vector will then contain only zeros.
	 * IMPORTANT: the code considers the indices as location in the mesh subgemeometry indices vector, not the value at the pointer location.
	 *
	 * @param mesh                Mesh. The mesh to remove a face from
	 * @param indices            A vector with a series of uints indices: the indices of the faces to be removed.
	 * @param subGeomIndices        A vector with a series of uints indices representing the subgeometries of the faces to be removed.
	 */

    static public function removeFaces(mesh:Mesh, indices:Vector<UInt>, subGeomIndices:Vector<UInt>):Void {
        var i:Int = 0;
        while (i < indices.length) {
            removeFace(mesh, indices[i], subGeomIndices[i]);
            ++i;
        }
    }

/**
	 * Adds a series of faces from a mesh. All vectors must have the same length.
	 * @param mesh    Mesh. The mesh to remove a face from
	 * @param v0s    A vector with a series of Vertex Objects representing the v0 of a face.
	 * @param v1s    A vector with a series of Vertex Objects representing the v1 of a face.
	 * @param v2s    A vector with a series of Vertex Objects representing the v2 of a face.
	 * @param uv0s    A vector with a series of UV Objects representing the uv0 of a face.
	 * @param uv1s    A vector with a series of UV Objects representing the uv1 of a face.
	 * @param uv2s    A vector with a series of UV Objects representing the uv2 of a face.
	 */

    static public function addFaces(mesh:Mesh, v0s:Vector<Vertex>, v1s:Vector<Vertex>, v2s:Vector<Vertex>, uv0s:Vector<UV>, uv1s:Vector<UV>, uv2s:Vector<UV>, subGeomIndices:Vector<UInt>):Void {
        var i:Int = 0;
        while (i < v0s.length) {
            addFace(mesh, v0s[i], v1s[i], v2s[i], uv0s[i], uv1s[i], uv2s[i], subGeomIndices[i]);
            ++i;
        }
    }

/**
	 * Divides a face into 2 faces.
	 * @param    mesh            The mesh holding the face to split in 2
	 * @param    indice            The face index. The value represents the position in indices vector divided by 3.
	 * For instance, to edit face [1], the parameter indice will be 1. The x value of the v0 at position 9 in vertices vector is then extracted from vertices[indices[indice*3]]
	 * @param    subGeomIndice    The index of the subgeometry holder this face.
	 * @param    side            [optional] The side of the face to split in two. 0 , 1 or 2. (clockwize).
	 */

    static public function splitFace(mesh:Mesh, indice:Int, subGeomIndice:Int, side:Int = 0):Void {
        var pointer:Int = indice * 3;
        var subGeom:SubGeometry = getSubGeometry(mesh, subGeomIndice);
        var indices:Vector<UInt> = subGeom.indexData.concat();
        if (pointer > indices.length - 3) throw new Error("ERROR >> face index out of range! Use the location in indice vector /3. For example, pass 1 if you want edit face 1, not 3!");
        var vertices:Vector<Float> = subGeom.vertexData.concat();
        if (indices.length + 3 > LIMIT || vertices.length + 9 > LIMIT) {
            trace("splitFace cannot take place, not enough room in target subGeometry");
            return;
        }
        var uvs:Vector<Float> = subGeom.UVData.concat();
        var normals:Vector<Float> = subGeom.vertexNormalData.concat();
        var tangents:Vector<Float> = subGeom.vertexTangentData.concat();
        var pointerverts:Int = indices[pointer] * 3;
        var v0:Vertex = new Vertex(vertices[pointerverts], vertices[pointerverts + 1], vertices[pointerverts + 2]);
        var n0:Vertex = new Vertex(normals[pointerverts], normals[pointerverts + 1], normals[pointerverts + 2]);
        var t0:Vertex = new Vertex(tangents[pointerverts], tangents[pointerverts + 1], tangents[pointerverts + 2]);
        pointerverts = indices[pointer + 1] * 3;
        var v1:Vertex = new Vertex(vertices[pointerverts], vertices[pointerverts + 1], vertices[pointerverts + 2]);
        var n1:Vertex = new Vertex(normals[pointerverts], normals[pointerverts + 1], normals[pointerverts + 2]);
        var t1:Vertex = new Vertex(tangents[pointerverts], tangents[pointerverts + 1], tangents[pointerverts + 2]);
        pointerverts = indices[pointer + 2] * 3;
        var v2:Vertex = new Vertex(vertices[pointerverts], vertices[pointerverts + 1], vertices[pointerverts + 2]);
        var n2:Vertex = new Vertex(normals[pointerverts], normals[pointerverts + 1], normals[pointerverts + 2]);
        var t2:Vertex = new Vertex(tangents[pointerverts], tangents[pointerverts + 1], tangents[pointerverts + 2]);
        var pointeruv:Int = indices[pointer] * 2;
        var uv0:UV = new UV(uvs[pointeruv], uvs[pointeruv + 1]);
        pointeruv = indices[pointer + 1] * 2;
        var uv1:UV = new UV(uvs[pointeruv], uvs[pointeruv + 1]);
        pointeruv = indices[pointer + 2] * 2;
        var uv2:UV = new UV(uvs[pointeruv], uvs[pointeruv + 1]);
        var vlength:Int = indices.length;
        indices[vlength] = vlength / 3;
        var targetIndice:Int;
        switch(side) {
            case 0:
                vertices.push((v0.x + v1.x) * .5, (v0.y + v1.y) * .5, (v0.z + v1.z) * .5);
                normals.push((n0.x + n1.x) * .5, (n0.y + n1.y) * .5, (n0.z + n1.z) * .5);
                tangents.push((t0.x + t1.x) * .5, (t0.y + t1.y) * .5, (t0.z + t1.z) * .5);
                uvs.push((uv0.u + uv1.u) * .5, (uv0.v + uv1.v) * .5);
                targetIndice = indices[(indice * 3) + 1];
                indices[(indice * 3) + 1] = (vertices.length - 1) / 3;
                indices[vlength++] = indices[pointer + 1];
                indices[vlength++] = targetIndice;
                indices[vlength++] = indices[pointer + 2];
            case 1:
                vertices.push((v1.x + v2.x) * .5, (v1.y + v2.y) * .5, (v1.z + v2.z) * .5);
                normals.push((n1.x + n2.x) * .5, (n1.y + n2.y) * .5, (n1.z + n2.z) * .5);
                tangents.push((t1.x + t2.x) * .5, (t1.y + t2.y) * .5, (t1.z + t2.z) * .5);
                uvs.push((uv1.u + uv2.u) * .5, (uv1.v + uv2.v) * .5);
                targetIndice = indices[(indice * 3) + 2];
                indices[(indice * 3) + 2] = targetIndice;
                indices[vlength++] = (vertices.length - 1) / 3;
                indices[vlength++] = indices[pointer + 2];
                indices[vlength++] = indices[pointer];
            default:
                vertices.push((v2.x + v0.x) * .5, (v2.y + v0.y) * .5, (v2.z + v0.z) * .5);
                normals.push((n2.x + n0.x) * .5, (n2.y + n0.y) * .5, (n2.z + n0.z) * .5);
                tangents.push((t2.x + t0.x) * .5, (t2.y + t0.y) * .5, (t2.z + t0.z) * .5);
                uvs.push((uv2.u + uv0.u) * .5, (uv2.v + uv0.v) * .5);
                targetIndice = indices[indice * 3];
                indices[indice * 3] = targetIndice;
                indices[vlength++] = (vertices.length - 1) / 3;
                indices[vlength++] = indices[pointer];
                indices[vlength++] = indices[pointer + 1];
        }
        v0 = v1 = v2 = n0 = n1 = n2 = t0 = t1 = t2 = null;
        uv0 = uv1 = uv2 = null;
        updateSubGeometryData(subGeom, vertices, indices, uvs, normals, tangents);
    }

/**
	 * Divides a face into 3 faces.
	 * @param    mesh            The mesh holding the face to split in 3.
	 * @param    indice        The face index. The value represents the position in indices vector divided by 3.
	 * For instance, to edit face [1], the parameter indice will be 1. The x value of the v0 at position 9 in vertices vector is then extracted from vertices[indices[indice*3]]
	 * @param    subGeomIndice            The index of the subgeometry holder this face.
	 */

    static public function triFace(mesh:Mesh, indice:Int, subGeomIndice:Int):Void {
        var pointer:Int = indice * 3;
        var subGeom:SubGeometry = getSubGeometry(mesh, subGeomIndice);
        var indices:Vector<UInt> = subGeom.indexData.concat();
        if (pointer > indices.length - 3) throw new Error("ERROR >> face index out of range! Use the location in indice vector /3. For example, pass 1 if you want edit face 1, not 3!");
        var vertices:Vector<Float> = subGeom.vertexData.concat();
        if (indices.length + 6 > LIMIT || vertices.length + 18 > LIMIT) {
            trace("triFace cannot take place, not enough room in target subGeometry");
            return;
        }
        var uvs:Vector<Float> = subGeom.UVData.concat();
        var normals:Vector<Float> = subGeom.vertexNormalData.concat();
        var tangents:Vector<Float> = subGeom.vertexTangentData.concat();
        var pointerverts:Int = indices[pointer] * 3;
        var v0:Vertex = new Vertex(vertices[pointerverts], vertices[pointerverts + 1], vertices[pointerverts + 2]);
        var n0:Vertex = new Vertex(normals[pointerverts], normals[pointerverts + 1], normals[pointerverts + 2]);
        var t0:Vertex = new Vertex(tangents[pointerverts], tangents[pointerverts + 1], tangents[pointerverts + 2]);
        pointerverts = indices[pointer + 1] * 3;
        var v1:Vertex = new Vertex(vertices[pointerverts], vertices[pointerverts + 1], vertices[pointerverts + 2]);
        var n1:Vertex = new Vertex(normals[pointerverts], normals[pointerverts + 1], normals[pointerverts + 2]);
        var t1:Vertex = new Vertex(tangents[pointerverts], tangents[pointerverts + 1], tangents[pointerverts + 2]);
        pointerverts = indices[pointer + 2] * 3;
        var v2:Vertex = new Vertex(vertices[pointerverts], vertices[pointerverts + 1], vertices[pointerverts + 2]);
        var n2:Vertex = new Vertex(normals[pointerverts], normals[pointerverts + 1], normals[pointerverts + 2]);
        var t2:Vertex = new Vertex(tangents[pointerverts], tangents[pointerverts + 1], tangents[pointerverts + 2]);
        var pointeruv:Int = indices[pointer] * 2;
        var uv0:UV = new UV(uvs[pointeruv], uvs[pointeruv + 1]);
        pointeruv = indices[pointer + 1] * 2;
        var uv1:UV = new UV(uvs[pointeruv], uvs[pointeruv + 1]);
        pointeruv = indices[pointer + 2] * 2;
        var uv2:UV = new UV(uvs[pointeruv], uvs[pointeruv + 1]);
        vertices.push((v0.x + v1.x + v2.x) / 3, (v0.y + v1.y + v2.y) / 3, (v0.z + v1.z + v2.z) / 3);
        normals.push((n0.x + n1.x + n2.x) / 3, (n0.y + n1.y + n2.y) / 3, (n0.z + n1.z + n2.z) / 3);
        tangents.push((t0.x + t1.x + t2.x) / 3, (t0.y + t1.y + t2.y) / 3, (t0.z + t1.z + t2.z) / 3);
        uvs.push((uv0.u + uv1.u + uv2.u) / 3, (uv0.v + uv1.v + uv2.v) / 3);
        var vlength:Int = indices.length;
        var ind:Int = vlength / 3;
        indices[(indice * 3) + 2] = (vertices.length - 1) / 3;
        indices[vlength++] = ind;
        indices[vlength++] = indices[pointer];
        indices[vlength++] = indices[pointer + 2];
        indices[vlength++] = indices[pointer + 1];
        indices[vlength++] = ind;
        indices[vlength++] = indices[pointer + 2];
        v0 = v1 = v2 = n0 = n1 = n2 = t0 = t1 = t2 = null;
        uv0 = uv1 = uv2 = null;
        updateSubGeometryData(subGeom, vertices, indices, uvs, normals, tangents);
    }

/**
	 * Divides a face into 4 faces.
	 * @param    mesh            The mesh holding the face to split in 4.
	 * @param    indice        The face index. The value represents the position in indices vector divided by 3.
	 * For instance, to edit face [1], the parameter indice will be 1. The x value of the v0 at position 9 in vertices vector is then extracted from vertices[indices[indice*3]]
	 * @param    subGeomIndice            The index of the subgeometry holder this face.
	 */

    static public function quarterFace(mesh:Mesh, indice:Int, subGeomIndice:Int):Void {
        var pointer:Int = indice * 3;
        var subGeom:SubGeometry = getSubGeometry(mesh, subGeomIndice);
        var indices:Vector<UInt> = subGeom.indexData.concat();
        if (pointer > indices.length - 3) throw new Error("ERROR >> face index out of range! Use the location in indice vector /3. For example, pass 1 if you want edit face 1, not 3!");
        var vertices:Vector<Float> = subGeom.vertexData.concat();
        if (indices.length + 9 > LIMIT || vertices.length + 27 > LIMIT) {
            trace("quarterFace cannot take place, not enough room in target subGeometry");
            return;
        }
        var uvs:Vector<Float> = subGeom.UVData.concat();
        var normals:Vector<Float> = subGeom.vertexNormalData.concat();
        var tangents:Vector<Float> = subGeom.vertexTangentData.concat();
        var pointerverts:Int = indices[pointer] * 3;
        var v0:Vertex = new Vertex(vertices[pointerverts], vertices[pointerverts + 1], vertices[pointerverts + 2]);
        var n0:Vertex = new Vertex(normals[pointerverts], normals[pointerverts + 1], normals[pointerverts + 2]);
        var t0:Vertex = new Vertex(tangents[pointerverts], tangents[pointerverts + 1], tangents[pointerverts + 2]);
        pointerverts = indices[pointer + 1] * 3;
        var v1:Vertex = new Vertex(vertices[pointerverts], vertices[pointerverts + 1], vertices[pointerverts + 2]);
        var n1:Vertex = new Vertex(normals[pointerverts], normals[pointerverts + 1], normals[pointerverts + 2]);
        var t1:Vertex = new Vertex(tangents[pointerverts], tangents[pointerverts + 1], tangents[pointerverts + 2]);
        pointerverts = indices[pointer + 2] * 3;
        var v2:Vertex = new Vertex(vertices[pointerverts], vertices[pointerverts + 1], vertices[pointerverts + 2]);
        var n2:Vertex = new Vertex(normals[pointerverts], normals[pointerverts + 1], normals[pointerverts + 2]);
        var t2:Vertex = new Vertex(tangents[pointerverts], tangents[pointerverts + 1], tangents[pointerverts + 2]);
        var pointeruv:Int = indices[pointer] * 2;
        var uv0:UV = new UV(uvs[pointeruv], uvs[pointeruv + 1]);
        pointeruv = indices[pointer + 1] * 2;
        var uv1:UV = new UV(uvs[pointeruv], uvs[pointeruv + 1]);
        pointeruv = indices[pointer + 2] * 2;
        var uv2:UV = new UV(uvs[pointeruv], uvs[pointeruv + 1]);
        var vind1:Int = vertices.length / 3;
        vertices.push((v0.x + v1.x) * .5, (v0.y + v1.y) * .5, (v0.z + v1.z) * .5);
        normals.push((n0.x + n1.x) * .5, (n0.y + n1.y) * .5, (n0.z + n1.z) * .5);
        tangents.push((t0.x + t1.x) * .5, (t0.y + t1.y) * .5, (t0.z + t1.z) * .5);
        uvs.push((uv0.u + uv1.u) * .5, (uv0.v + uv1.v) * .5);
        var vind2:Int = vertices.length / 3;
        vertices.push((v1.x + v2.x) * .5, (v1.y + v2.y) * .5, (v1.z + v2.z) * .5);
        normals.push((n1.x + n2.x) * .5, (n1.y + n2.y) * .5, (n1.z + n2.z) * .5);
        tangents.push((t1.x + t2.x) * .5, (t1.y + t2.y) * .5, (t1.z + t2.z) * .5);
        uvs.push((uv1.u + uv2.u) * .5, (uv1.v + uv2.v) * .5);
        var vind3:Int = vertices.length / 3;
        vertices.push((v2.x + v0.x) * .5, (v2.y + v0.y) * .5, (v2.z + v0.z) * .5);
        normals.push((n2.x + n0.x) * .5, (n2.y + n0.y) * .5, (n2.z + n0.z) * .5);
        tangents.push((t2.x + t0.x) * .5, (t2.y + t0.y) * .5, (t2.z + t0.z) * .5);
        uvs.push((uv2.u + uv0.u) * .5, (uv2.v + uv0.v) * .5);
        var vlength:Int = indices.length;
        indices[vlength++] = vind2;
        indices[vlength++] = indices[pointer + 2];
        indices[vlength++] = vind3;
        indices[vlength++] = vind2;
        indices[vlength++] = vind3;
        indices[vlength++] = vind1;
        indices[vlength++] = vind2;
        indices[vlength++] = vind1;
        indices[vlength++] = indices[pointer + 1];
        indices[(indice * 3) + 1] = vind1;
        indices[(indice * 3) + 2] = vind3;
        v0 = v1 = v2 = n0 = n1 = n2 = t0 = t1 = t2 = null;
        uv0 = uv1 = uv2 = null;
        updateSubGeometryData(subGeom, vertices, indices, uvs, normals, tangents);
    }

/**
	 * Divides all the faces of a mesh in 2 faces.
	 * @param    mesh        The mesh holding the faces to split in 2
	 * @param    face        The face index. The value represents the position in indices vector divided by 3.
	 * @param    side        The side of the face to split in two. 0 , 1 or 2. (clockwize).
	 * At this time of dev, splitFaces method will abort if a subgeometry reaches max buffer limit of 65k
	 */

    static public function splitFaces(mesh:Mesh):Void {
        applyMethod(SPLIT, mesh);
    }

/**
	 * Divides all the faces of a mesh in 3 faces.
	 * @param    mesh        The mesh holding the faces to split in 3
	 * At this time of dev, triFaces method will abort if a subgeometry reaches max buffer limit of 65k
	 */

    static public function triFaces(mesh:Mesh):Void {
        applyMethod(TRI, mesh);
    }

/**
	 * Divides all the faces of a mesh in 4 faces.
	 * @param    mesh        The mesh holding the faces to split in 4
	 * At this time of dev, quarterFaces method will abort if a subgeometry reaches max buffer limit of 65k
	 */

    static public function quarterFaces(mesh:Mesh):Void {
        applyMethod(QUARTER, mesh);
    }

    static public function getFaceNormal(v0:Vertex, v1:Vertex, v2:Vertex, out:Vertex = null):Vertex {
        var dx1:Float = v2.x - v0.x;
        var dy1:Float = v2.y - v0.y;
        var dz1:Float = v2.z - v0.z;
        var dx2:Float = v1.x - v0.x;
        var dy2:Float = v1.y - v0.y;
        var dz2:Float = v1.z - v0.z;
        var cx:Float = dz1 * dy2 - dy1 * dz2;
        var cy:Float = dx1 * dz2 - dz1 * dx2;
        var cz:Float = dy1 * dx2 - dx1 * dy2;
        var d:Float = 1 / Math.sqrt(cx * cx + cy * cy + cz * cz);
        var normal:Vertex = out || new Vertex(0.0, 0.0, 0.0);
        normal.x = cx * d;
        normal.y = cy * d;
        normal.z = cz * d;
        return normal;
    }

    static public function getFaceTangent(v0:Vertex, v1:Vertex, v2:Vertex, uv0V:Float, uv1V:Float, uv2V:Float, uvScaleV:Float = 1, out:Vertex = null):Vertex {
        var invScale:Float = 1 / uvScaleV;
        var dv0:Float = uv0V;
        var dv1:Float = (uv1V - dv0) * invScale;
        var dv2:Float = (uv2V - dv0) * invScale;
        var x0:Float = v0.x;
        var y0:Float = v0.y;
        var z0:Float = v0.z;
        var dx1:Float = v1.x - x0;
        var dy1:Float = v1.y - y0;
        var dz1:Float = v1.z - z0;
        var dx2:Float = v2.x - x0;
        var dy2:Float = v2.y - y0;
        var dz2:Float = v2.z - z0;
        var tangent:Vertex = out || new Vertex(0.0, 0.0, 0.0);
        var cx:Float = dv2 * dx1 - dv1 * dx2;
        var cy:Float = dv2 * dy1 - dv1 * dy2;
        var cz:Float = dv2 * dz1 - dv1 * dz2;
        var denom:Float = 1 / Math.sqrt(cx * cx + cy * cy + cz * cz);
        tangent.x = denom * cx;
        tangent.y = denom * cy;
        tangent.z = denom * cz;
        return tangent;
    }

    static private function applyMethod(methodID:Int, mesh:Mesh, value:Float = 0):Void {
        var subGeoms:Vector<ISubGeometry> = mesh.geometry.subGeometries;
        if (Std.is(subGeoms[0], CompactSubGeometry)) throw new Error("Convert to CompactSubGeometry using mesh.geometry.convertToSeparateBuffers() ");
        var indices:Vector<UInt>;
        var faceIndex:Int;
        var j:Int;
        var i:Int = 0;
        while (i < subGeoms.length) {
            indices = subGeoms[i].indexData;
            faceIndex = 0;
            j = 0;
            while (j < indices.length) {
                faceIndex = j / 3;
                switch(methodID) {
                    case 2:
                        splitFace(mesh, faceIndex, i, 0);
                    case 3:
                        triFace(mesh, faceIndex, i);
                    case 4:
                        quarterFace(mesh, faceIndex, i);
                    default:
                        throw new Error("unknown method reference");
                }
                j += 3;
            }
            ++i;
        }
    }

    static private function updateSubGeometryData(subGeometry:SubGeometry, vertices:Vector<Float>, indices:Vector<UInt>, uvs:Vector<Float>, normals:Vector<Float> = null, tangents:Vector<Float> = null):Void {
        subGeometry.updateVertexData(vertices);
        subGeometry.updateIndexData(indices);
        if (normals) subGeometry.updateVertexNormalData(normals);
        if (tangents) subGeometry.updateVertexTangentData(tangents);
        subGeometry.updateUVData(uvs);
    }

    static private function getSubGeometry(mesh:Mesh, subGeomIndice:Int):SubGeometry {
        var subGeoms:Vector<ISubGeometry> = mesh.geometry.subGeometries;
        if (Std.is(subGeoms[0], CompactSubGeometry)) throw new Error("Convert to CompactSubGeometry using mesh.geometry.convertToSeparateBuffers() ");
        if (subGeomIndice > subGeoms.length - 1) throw new Error("ERROR >> subGeomIndice is out of range!");
        return cast((subGeoms[subGeomIndice]), SubGeometry);
    }

    static private function getUsedIndice(vertices:Vector<Float>, x:Float, y:Float, z:Float):Int {
        var i:Int = 0;
        while (i < vertices.length) {
            if (vertices[i] == x && vertices[i + 1] == y && vertices[i + 1] == z) return i / 3;
            i += 3;
        }
        return -1;
    }

}

