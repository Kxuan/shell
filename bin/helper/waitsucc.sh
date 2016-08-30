#!/bin/bash

utilok() {
    until $@;do :; done
}
