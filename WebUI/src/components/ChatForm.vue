<template>
  <div id="chat-form" v-show="IsTypingActive">
    <input ref="messageInput" type="text" class="message-input" maxLength="127"
        v-model="inputMessage" v-on:keyup="OnKeyPressed" v-on:blur="OnBlur"/>
      <label ref="target" class="chat-target">
        {{ GetTarget }}
      </label>
    </div>
</template>

<script>
import { mapGetters, mapActions } from 'vuex';

export default {
    data: () => ({
        inputMessage: ''
    }),
    computed: {
        ...mapGetters(['IsTypingActive', 'GetTarget']),
        ...mapActions(['EnableTyping', 'DisableTyping'])
    },
    methods: {
        OnSubmit (event) {
            if (this.inputMessage.length === 0) {
                this.$store.dispatch('DisableTyping');
                return;
            }

            event.preventDefault();

            this.$vext.DispatchEventLocal('AC:SendChatMessage', this.GetTarget + ':' + this.inputMessage);

            this.ResetInputMessage();
            this.$store.dispatch('DisableTyping');
        },
        ResetInputMessage () {
            this.inputMessage = '';
        },

        OnKeyPressed (event) {
            switch (event.key) {
            case 'Enter':
                this.OnSubmit(event);
                break;
            case 'Escape':
                this.$store.dispatch('DisableTyping');
                break;
            case 'ArrowUp':
                this.$emit('scroll-up');
                break;
            case 'ArrowDown':
                this.$emit('scroll-down');
                break;
            }
        },

        OnBlur () {
            this.$store.dispatch('DisableTyping');
        }
    },
    watch: {
        IsTypingActive (shouldFocus) {
            if (shouldFocus) {
                this.$nextTick(() => this.$refs.messageInput.focus());
            }
        }
    }
};
</script>

<style lang="scss" scoped>
  #chat-form {
    width: 380px;
    position: absolute;
    bottom: 24px;
    left: 10px;
    right: 10px;
    color: #fff;
    height: 25px;

    .message-input {
      width: 100%;
      box-sizing: border-box;
      background: rgba(3, 10, 15, 0.2);
      border: none;
      color: #fff;
      line-height: 20px;
      font-family: 'Blinker';
      font-size: 13px;
      padding: 0 10px 0 45px;

      &:focus, &:active {
        border: none;
        outline: 0;
      }
    }

    .chat-target {
      position: absolute;
      top: 5px;
      left: 5px;
      text-transform: uppercase;
      font-family: 'Blinker';
      font-size: 13px;
    }

    &.inactive {
      .chat-target {
        display: none;
      }
    }
  }
</style>
