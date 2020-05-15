#!/bin/bash

for i in *_demo_*.sh; do qsub "$i"; sleep 3; done

