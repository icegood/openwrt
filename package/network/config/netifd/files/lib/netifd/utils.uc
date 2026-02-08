'use strict';

import { glob, basename, realpath, chdir, mkstemp } from "fs";

export const TYPE_ARRAY = 1;
export const TYPE_STRING = 3;
export const TYPE_INT = 5;
export const TYPE_BOOL = 7;

export function parse_bool(val)
{
	switch (val) {
	case "1":
	case "true":
		return true;
	case "0":
	case "false":
		return false;
	}
};

export function parse_array(val)
{
	if (type(val) != "array")
		val = split(val, /\s+/);
	return val;
};

function __type_parsers()
{
	let ret = [];

	ret[TYPE_ARRAY] = parse_array;
	ret[TYPE_STRING] = function(val) {
		return val;
	};
	ret[TYPE_INT] = function(val) {
		return +val;
	};
	ret[TYPE_BOOL] = parse_bool;

	return ret;
}
export const type_parser = __type_parsers();

function safe_system_call(command) {
	let fout = mkstemp();
	let ferr = mkstemp();

	let ret = system(`${command} 1>&${fout.fileno()} 2>&${ferr.fileno()}`);

	ferr.seek();
	let err = ferr.read("all");
	ferr.close();
	fout.seek();
	let out = fout.read("all");
	fout.close();
	return {
		out: out,
		err: err,
		ret: ret
	};
};

export function handler_load(path, cb)
{
	for (let script in glob(path + "/*.sh")) {
		script = basename(script);
		netifd.log(netifd.L_DEBUG,`To load ${script} in handler`);

		
		let prev_dir = realpath(".");
		chdir(path);
		let res = safe_system_call(`./${script} "" "dump"`);
		chdir(prev_dir);
		
		if (res.ret) {
			netifd.log(netifd.L_WARNING,`Cannot load ${script}: ret=${res.ret}, err=${res.err}`);
			continue;
		}
		for (let data in map(split(res.out, '\n'), (v) => trim(v))) {
			try {
				data = json(data);
			} catch (e) {
				continue;
			}

			if (type(data) != "object")
				continue;

			cb(script, data);
		}
	}
};

export function handler_attributes(data, extra, validate)
{
	let ret = { ...extra };
	for (let cur in data) {
		let name_data = split(cur[0], ":", 2);
		let name = name_data[0];
		ret[name] = cur[1];
		if (validate && name_data[1])
			validate[name] = name_data[1];
	}
	return ret;
};

export function parse_attribute_list(data, spec)
{
	let ret = {};

	for (let name, type_id in spec) {
		if (!(name in data))
			continue;

		let val = data[name];
		let parser = type_parser[type_id];
		if (parser)
			val = parser(val);
		ret[name] = val;
	}

	return ret;
};

export function is_equal(val1, val2) {
	let t1 = type(val1);

	if (t1 != type(val2))
		return false;

	if (t1 == "array") {
		if (length(val1) != length(val2))
			return false;

		for (let i = 0; i < length(val1); i++)
			if (!is_equal(val1[i], val2[i]))
				return false;

		return true;
	} else if (t1 == "object") {
		for (let key in val1)
			if (!is_equal(val1[key], val2[key]))
				return false;
		for (let key in val2)
			if (val1[key] == null)
				return false;
		return true;
	} else {
		return val1 == val2;
	}
};
