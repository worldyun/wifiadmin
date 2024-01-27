<script setup lang="ts">
import { message } from "@/utils/message";
import TypeIt from "@/components/ReTypeit";
import { getapi, postapi } from "@/api/user";
import { ElMessageBox } from 'element-plus';
import { ref, onMounted, reactive } from 'vue';
defineOptions({
  name: "SimSwitch"
});
const info = ref()
const activeNames = ref(['1']);
let load_switch = ref(true);//默认加载中
//表单字段定义
const ruleForm = reactive({
  cstm_webui_simswitch: '',//
  sim_auto_switch_enable: '',//是否启用自动切换
  sim_current_type: '',//当前SIM卡 0-外置卡 1-内置卡1 2-内置卡2
  sim_default_type: '',//默认SIM卡 0-外置卡 1-内置卡1 2-内置卡2
  sim_lock_status: '',//SIM卡解锁状态
  sim_switch_number: '',//未知，可能是卡片数量？
  sim_switch_running_detect: '',//检测运行时状态
})
//页面加载完成
onMounted(() => {
  init();
});
function init() {
    //获取SIM卡信息
  getapi('cmd=sim_switch_number%2Csim_auto_switch_enable%2Csim_current_type%2Csim_switch_running_detect%2Csim_default_type%2Csim_lock_status%2Ccstm_webui_simswitch&multi_data=1').then(res => {
    ruleForm.cstm_webui_simswitch = res.cstm_webui_simswitch;
    ruleForm.sim_auto_switch_enable = res.sim_auto_switch_enable;
    ruleForm.sim_current_type = res.sim_current_type;
    ruleForm.sim_default_type = res.sim_default_type;
    ruleForm.sim_lock_status = res.sim_lock_status;
    ruleForm.sim_switch_number = res.sim_switch_number;
    ruleForm.sim_switch_running_detect = res.sim_switch_running_detect;
    load_switch.value = false;
  }).catch(error => {
      load_switch.value = false;
      console.log('加载失败');
  });
}
function submitForm() {
    load_switch.value = true;
    //当自动切换SIM功能关闭时顺手也关了检测运行时状态
    if (ruleForm.sim_auto_switch_enable != '1') {
      ruleForm.sim_switch_running_detect = '0';
    }
    postapi({
      sim_auto_switch_enable: ruleForm.sim_auto_switch_enable,
      sim_default_type: ruleForm.sim_default_type,
      sim_switch_running_detect: ruleForm.sim_switch_running_detect,
      goformId: "SIM_SWITCH"
    }).then(res => {
      if (res.result == "success") {
        init();
        message("成功发送请求", { type: "success" });
      } else {
        message("操作失败", { type: "error" });
        load_switch.value = false;
      }
    }).catch(error => {
      message("请求失败", { type: "error" });
      load_switch.value = false;
    });
}
</script>
<template>
  <div>
    <el-row :gutter="24">
      <el-col :xs="24" :sm="24" :md="16" :lg="16" :xl="16" class="mb-[5px]" v-motion :initial="{ opacity: 0, y: 100 }"
        :enter="{ opacity: 1, y: 0, transition: { delay: 200 } }">
        <b v-if="ruleForm.sim_lock_status != 'unlock'">
          很高兴地通知你: SIM卡未解锁。你需要先刷回原版后台解锁, 或者使用其他工具解锁后再使用此功能。为啥不写解锁功能呢, 因为解锁是一个一次性功能, 第一次解锁后就再也不需要解锁了。 
        </b>
        <el-card  shadow="never" v-loading="load_switch" v-if="ruleForm.sim_lock_status == 'unlock'">
          <template #header>
            <TypeIt :className="'type-it1'" :values="['SIM卡选择']" :cursor="false" :speed="60" />
          </template>
          <template #default>
            <div class="form-container">
              <el-form ref="ruleFormRef" :model="ruleForm" status-icon label-width="120px" class="demo-ruleForm"
                label-position="left">
                <el-form-item label="当前SIM卡" prop="sim_current_type">
                  <el-select v-model="ruleForm.sim_current_type" :fit-input-width="true" style="width: 100%;" disabled>
                    <el-option label="外置卡" value="0" />
                    <el-option label="内置卡1" value="1" />
                    <el-option label="内置卡2" value="2" />
                  </el-select>
                </el-form-item>
                <el-form-item label="默认SIM卡" prop="sim_default_type">
                  <el-select v-model="ruleForm.sim_default_type" :fit-input-width="true" style="width: 100%;">
                    <el-option label="外置卡" value="0" />
                    <el-option label="内置卡1" value="1" />
                    <el-option label="内置卡2" value="2" />
                  </el-select>
                </el-form-item>
                <el-form-item label="自动切换" prop="sim_auto_switch_enable">
                  <el-select v-model="ruleForm.sim_auto_switch_enable" :fit-input-width="true" style="width: 100%;">
                    <el-option label="关闭" value="0" />
                    <el-option label="启用" value="1" />
                  </el-select>
                </el-form-item>
                <el-form-item v-show="ruleForm.sim_auto_switch_enable == 1" label="检测运行时状态" prop="sim_switch_running_detect">
                  <el-select v-model="ruleForm.sim_switch_running_detect" :fit-input-width="true" style="width: 100%;">
                    <el-option label="关闭" value="0" />
                    <el-option label="启用" value="1" />
                  </el-select>
                </el-form-item>
                <el-form-item class="form-buttons">
                  <el-button type="primary" @click="submitForm()">应用</el-button>
                </el-form-item>
                <el-button style="visibility: hidden;"></el-button>
              </el-form>
            </div>
          </template>
        </el-card>
      </el-col>
      <el-col :xs="24" :sm="24" :md="8" :lg="8" :xl="8" class="mb-[5px]" v-motion :initial="{ opacity: 0, y: 100 }"
        :enter="{ opacity: 1, y: 0, transition: { delay: 200 } }">
        <el-card shadow="never" v-loading="load_switch" v-if="ruleForm.sim_lock_status == 'unlock'">
          <template #header>
            <TypeIt :className="'type-it2'" :values="['设置说明']" :cursor="false" :speed="60" />
          </template>
          <template #default>
            <el-collapse v-model="activeNames">
              <el-collapse-item title="当前SIM卡" name="1">
                设备当前正在使用的SIM卡。
              </el-collapse-item>
              <el-collapse-item title="默认SIM卡" name="2">
                选择设备开机后默认使用的SIM卡。
              </el-collapse-item>
              <el-collapse-item title="自动切换" name="3">
                选择是否开启SIM卡自动切换, 如果启用, 设备将切换至能够连接网络的SIM卡。
              </el-collapse-item>
              <el-collapse-item title="检测运行时状态" name="4">
                我也不清楚是干啥的, 来个吊大的给我解释解释呗。
              </el-collapse-item>
            </el-collapse>
          </template>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>
<style lang="scss" scoped>
.form-container {
  position: relative;
}

.form-buttons {
  right: 0;
  display: flex;
  position: absolute;
  align-items: flex-end;
  justify-content: flex-end;
}
</style>