params ["_player",["_searchType","FAST_EXISTS_CHECK"]];

private ["_playerPosition","_intersectionRadius","_intersectionDistance","_intersectionTests","_lastIntersectStartASL","_lastIntersectionIntersected","_edges"];
private ["_edge","_x","_y","_directionUnitVector","_intersectStartASL","_intersectEndASL","_surfaces"];

_playerPosition = getPosASL _player;
_intersectionRadius = 1.5;
_intersectionDistance = 4;
_intersectionTests = 40;

if(_searchType == "FAST_EXISTS_CHECK") then {
	_intersectionTests = 8;
};

_lastIntersectStartASL = [];
_lastIntersectionIntersected = false;
_edges = [];
_edge = [];

_fastExistsEdgeFound = false;

// Search for nearby edges

for "_i" from 0 to _intersectionTests do
{
	_x = cos ((360/_intersectionTests)*_i);
	_y = sin ((360/_intersectionTests)*_i);
	_directionUnitVector = vectorNormalized [_x, _y, 0];
	_intersectStartASL = _playerPosition vectorAdd ( _directionUnitVector vectorMultiply _intersectionRadius )  vectorAdd [0,0,1.5];
	_intersectEndASL = _intersectStartASL vectorAdd [0,0,-5];
	_surfaces = lineIntersectsSurfaces [_intersectStartASL, _intersectEndASL, _player, objNull, true, 1];
	if(_searchType == "FAST_EXISTS_CHECK") then {
		if(count _surfaces == 0) exitWith { _fastExistsEdgeFound = true; };
	} else {
		if(count _surfaces > 0) then {
			if(!_lastIntersectionIntersected && _i != 0) then {
				// Moved from edge to no edge (edge end)
				_edge pushBack _lastIntersectStartASL;
				_edges pushBack _edge;
			};
			_lastIntersectionIntersected = true;
		} else {
			if(_lastIntersectionIntersected && _i != 0) then {
				// Moved from no edge to edge (edge start)
				_edge = [_intersectStartASL];
				if(_i == _intersectionTests) then {
					_edges pushBack _edge;
				};
			};
			_lastIntersectionIntersected = false;
		};
		_lastIntersectStartASL = _intersectStartASL;
	};
};

if(_searchType == "FAST_EXISTS_CHECK") exitWith { _fastExistsEdgeFound; };

// If edges found, return nearest edge

private ["_firstEdge","_largestEdgeDistance","_largestEdge","_edgeDistance","_edgeStart","_edgeEnd","_edgeMiddle","_edgeDirection"];

if(count _edge == 1) then {
	_firstEdge = _edges deleteAt 0;
	_edges deleteAt (count _edges - 1);
	_edges pushBack (_edge+_firstEdge);
};

_largestEdgeDistance = 0;
_largestEdge = [];
{
	_edgeDistance = (_x select 0) distance (_x select 1);
	if(_edgeDistance > _largestEdgeDistance) then {
		_largestEdgeDistance = _edgeDistance;
		_largestEdge = _x;
	};
} forEach _edges;

if(count _largestEdge > 0) then {
	_edgeStart = (_largestEdge select 0);
	_edgeStart set [2,getPosASL _player select 2];
	_edgeEnd = (_largestEdge select 1);
	_edgeEnd set [2,getPosASL _player select 2];
	_edgeMiddle = _edgeStart vectorAdd (( _edgeEnd vectorDiff _edgeStart ) vectorMultiply 0.5 );
	_edgeDirection = vectorNormalized (( _edgeStart vectorFromTo _edgeEnd ) vectorCrossProduct [0,0,1]);
	
	// Check to see if there's a surface we can attach the rope to (so it doesn't hang in the air)
	
	_playerPositionASL = getPosASL _player;
	
	_intersectStartASL = _playerPositionASL vectorAdd ((_playerPositionASL vectorFromTo _edgeStart) vectorMultiply (_intersectionRadius));
	_intersectEndASL = _intersectStartASL vectorAdd ((_intersectStartASL vectorFromTo _playerPositionASL) vectorMultiply (_intersectionRadius * 2)) vectorAdd [0,0,-0.5];
	_surfaces = lineIntersectsSurfaces [_intersectStartASL, _intersectEndASL, _player, objNull, true, 1, "FIRE", "NONE"];
	if(count _surfaces > 0) then {
		_edgeStart = (_surfaces select 0) select 0;
	};
	
	_intersectStartASL = _playerPositionASL vectorAdd ((_playerPositionASL vectorFromTo _edgeEnd) vectorMultiply (_intersectionRadius));
	_intersectEndASL = _intersectStartASL vectorAdd ((_intersectStartASL vectorFromTo _playerPositionASL) vectorMultiply (_intersectionRadius * 2)) vectorAdd [0,0,-0.5];
	_surfaces = lineIntersectsSurfaces [_intersectStartASL, _intersectEndASL, _player, objNull, true, 1, "FIRE", "NONE"];
	if(count _surfaces > 0) then {
		_edgeEnd = (_surfaces select 0) select 0;
	};
	
	_intersectStartASL = _playerPositionASL vectorAdd ((_playerPositionASL vectorFromTo _edgeMiddle) vectorMultiply (_intersectionRadius));
	_intersectEndASL = _intersectStartASL vectorAdd ((_intersectStartASL vectorFromTo _playerPositionASL) vectorMultiply (_intersectionRadius * 2)) vectorAdd [0,0,-0.5];
	_surfaces = lineIntersectsSurfaces [_intersectStartASL, _intersectEndASL, _player, objNull, true, 1, "FIRE", "NONE"];
	if(count _surfaces > 0) then {
		_edgeMiddle = (_surfaces select 0) select 0;
	};
	
	// Check to make sure there's an opening for rappelling (to stop people from rappelling through a wall)
	_intersectStartASL = _playerPosition vectorAdd [0,0,1.5];
	_intersectEndASL = _intersectStartASL vectorAdd (_edgeDirection vectorMultiply 4);
	_surfaces = lineIntersectsSurfaces [_intersectStartASL, _intersectEndASL, _player, objNull, true, 1, "FIRE", "NONE"];
	if(count _surfaces > 0) exitWith { [] };

	[_edgeMiddle,_edgeDirection,[_edgeStart,_edgeEnd,_edgeMiddle]];
} else {
	[];
};