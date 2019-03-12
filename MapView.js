// MapView.js

import PropTypes from 'prop-types';
import React from 'react';
import {requireNativeComponent} from 'react-native';

class MapView extends React.Component {
    _onRegionChange = (event) => {
        if (!this.props.onRegionChange) {
            return;
        }

        // process raw event...
        this.props.onRegionChange(event.nativeEvent);
    }
    render() {
        return (
            <RNTMap
                {...this.props}
                onRegionChange={this._onRegionChange}
            />
        );
    }
}

MapView.propTypes = {
    /**
     * Callback that is called continuously when the user is dragging the map.
     */
    onRegionChange: PropTypes.func,
    /**
     * A Boolean value that determines whether the user may use pinch
     * gestures to zoom in and out of the map.
     */
    zoomEnabled: PropTypes.bool,

    /**
     * 地图要显示的区域。
     *
     * 区域由中心点坐标和区域范围坐标来定义。
     *
     */
    region: PropTypes.shape({
        /**
         * 地图中心点的坐标。
         */
        latitude: PropTypes.number.isRequired,
        longitude: PropTypes.number.isRequired,

        /**
         * 最小/最大经、纬度间的距离。
         *
         */
        latitudeDelta: PropTypes.number.isRequired,
        longitudeDelta: PropTypes.number.isRequired,
    }),
};

var RNTMap = requireNativeComponent('RNTMap', MapView);

export default MapView;
