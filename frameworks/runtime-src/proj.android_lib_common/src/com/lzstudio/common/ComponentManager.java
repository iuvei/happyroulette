package com.lzstudio.common;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

public class ComponentManager {
	private Map<String, Component> componMap = new ConcurrentHashMap<String, Component>(); 
	
	public void init(){
		for(Component compon : componMap.values()){
			compon.init();
		}
	}
	
	public void addComponent(String name, Component compon){
		if(!componMap.containsKey(name) && compon != null){
			compon.setName(name);
			componMap.put(name, compon);
		}
	}
	
	public Component getComponentByName(String name){
		return componMap.containsKey(name) ? componMap.get(name) : null;
	}
	
	public List<Component> findComponent(Class<?> clz){
		List<Component> components = new ArrayList<Component>();
		for(Component compon : componMap.values()){
			if(clz.isInstance(compon)){
				components.add(compon);
			}
		}
		return components;
	}
}
