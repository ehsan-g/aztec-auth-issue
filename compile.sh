#!/bin/bash

yarn compile:token
wait

yarn compile:factory
wait

yarn compile:router
wait
