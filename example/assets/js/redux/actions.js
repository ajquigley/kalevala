import { Creators as KalevalaCreators } from "../kalevala";

export const Creators = {
  moveNorth: () => {
    return (dispatch) => {
      const event = {
        topic: "system/send",
        data: { text: "north" }
      };

      dispatch(KalevalaCreators.socketSendEvent(event));
    };
  },
  moveSouth: () => {
    return (dispatch) => {
      const event = {
        topic: "system/send",
        data: { text: "south" }
      };

      dispatch(KalevalaCreators.socketSendEvent(event));
    };
  },
  moveWest: () => {
    return (dispatch) => {
      const event = {
        topic: "system/send",
        data: { text: "west" }
      };

      dispatch(KalevalaCreators.socketSendEvent(event));
    };
  },
  moveEast: () => {
    return (dispatch) => {
      const event = {
        topic: "system/send",
        data: { text: "east" }
      };

      dispatch(KalevalaCreators.socketSendEvent(event));
    };
  },
  moveUp: () => {
    return (dispatch) => {
      const event = {
        topic: "system/send",
        data: { text: "up" }
      };

      dispatch(KalevalaCreators.socketSendEvent(event));
    };
  },
  moveDown: () => {
    return (dispatch) => {
      const event = {
        topic: "system/send",
        data: { text: "down" }
      };

      dispatch(KalevalaCreators.socketSendEvent(event));
    };
  }
};
