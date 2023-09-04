<i18n>
en:
  not-binded: You have not binded RPE yet
  bind: Bind RPE
  binded: Binded successfully
  unbind: Unbind RPE
  unbinded: Unbinded successfully
  rpe-folder: Please select RPE's folder

  render: Render

zh-CN:
  not-binded: 你还没有绑定 RPE
  bind: 绑定 RPE
  binded: 绑定成功
  unbind: 解绑 RPE
  unbinded: 解绑成功
  rpe-folder: 请选择 RPE 所在文件夹

  render: 渲染

</i18n>

<script setup lang="ts">
import { ref } from 'vue';

import { useI18n } from 'vue-i18n';
const { t } = useI18n();

import { invoke } from '@tauri-apps/api';
import { convertFileSrc } from '@tauri-apps/api/tauri';
import { open } from '@tauri-apps/api/dialog';

import { toast, toastError } from './common';
import type { RPEChart } from './model';
import router from './router';

async function getRPECharts() {
  return (await invoke('get_rpe_charts')) as RPEChart[] | null;
}
const charts = ref(await getRPECharts());

async function bindRPE() {
  let file = await open({ directory: true, title: t('rpe-folder') });
  if (!file) return;
  try {
    await invoke('set_rpe_dir', { path: file });
    toast(t('binded'), 'success');
    charts.value = await getRPECharts();
  } catch (e) {
    toastError(e);
  }
}
async function unbindRPE() {
  try {
    await invoke('unset_rpe_dir');
    toast(t('unbinded'), 'success');
    charts.value = null;
  } catch (e) {
    toastError(e);
  }
}
</script>

<template>
  <div class="pa-8 w-100 h-100 d-flex flex-column" style="max-width: 1280px; gap: 1rem">
    <template v-if="!charts">
      <h1 class="text-center font-italic text-disabled" v-t="'not-binded'"></h1>
      <div class="d-flex justify-center">
        <v-btn size="large" class="italic mt-2" @click="bindRPE" style="width: fit-content" v-t="'bind'"></v-btn>
      </div>
    </template>
    <template v-if="charts">
      <div class="d-flex justify-center mb-4">
        <v-btn size="large" class="italic" @click="unbindRPE" style="width: fit-content" v-t="'unbind'"></v-btn>
      </div>
      <v-card v-for="chart in charts" :key="chart.id">
        <div class="d-flex flex-row align-stretch">
          <div class="d-flex flex-row align-center" style="width: 35%">
            <div
              style="width: 100%; height: 100%; max-height: 240px; background-position: center; background-repeat: no-repeat; background-size: cover"
              :style="{ 'background-image': 'url(' + convertFileSrc(chart.illustration) + ')' }"></div>
          </div>
          <div class="d-flex flex-column w-100">
            <v-card-title>{{ chart.name }}</v-card-title>
            <v-card-subtitle class="mt-n2">{{ chart.id }}</v-card-subtitle>
            <div class="w-100 pa-4 mt-2">
              <div class="pt-4 d-flex justify-end">
                <v-btn color="primary" @click="router.push({ name: 'render', query: { chart: chart.path } })" v-t="'render'"></v-btn>
              </div>
            </div>
          </div>
        </div>
      </v-card>
    </template>
  </div>
</template>
