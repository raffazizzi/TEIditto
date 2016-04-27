class TEIditto {
    
    constructor(){
        this.elTable = {};
        this.behaviors = {};
    }

    // public method
    getHTML5(TEI_url, cb){
        // Get TEI from TEI_url and create a promise
        let promise = new Promise( function (resolve, reject) {
            let client = new XMLHttpRequest();

            client.open('GET', TEI_url);
            client.send();

            client.onload = function () {
              if (this.status >= 200 && this.status < 300) {
                resolve(this.response);
              } else {
                reject(this.statusText);
              }
            };
            client.onerror = function () {
              reject(this.statusText);
            };
        })
        .then((TEI) => { 
            let TEI_dom = ( new window.DOMParser() ).parseFromString(TEI, "text/xml");
            this._fromTEI(TEI_dom);
            this._applyCustomElements();

            let newTree;
            let convertEl = (el) => {
                // Create new element
                let newElement = document.createElement(this.elTable[el.tagName]);
                // Copy attributes
                for (let att of Array.from(el.attributes)) {
                    newElement.setAttribute(att.name, att.value);
                }
                for (let node of Array.from(el.childNodes)){
                    if (node.nodeType == 1) {
                        newElement.appendChild(  convertEl(node)  );
                    }
                    else {
                        newElement.appendChild(node.cloneNode());
                    }
                }
                return newElement;
            }

            newTree = convertEl(TEI_dom.documentElement);

            if (cb) {
                cb(newTree);
            } 
            else {
                return newTree;
            }           

        })
        .catch( function(reason) {
            // TODO: better error handling?
            console.log(reason);
        });

        return promise;

    }

    // public method
    fromODD(){
        // Place holder for ODD-driven setup.
        // For example:
        // Create table of elements from ODD
        //    * default HTML behaviour mapping on/off (eg tei:div to html:div)
        //    ** phrase level elements behave like span (can I tell this from ODD classes?)
        //    * optional custom behaviour mapping
    }

    // public method
    addBehaviors(bhvs){
        for (let [el, bhv] of bhvs.entries()){
            if (["div", "span", "a"].indexOf(bhv)){
                this.behaviors[el] = bhv;
            }
        }
    }

    // "private" method
    _applyCustomElements() {
        for (let el of Object.keys(this.elTable)){
            let template;

            // Add behvior if available
            let bhv = this.behaviors[el];
            if (bhv) {
                switch (bhv) {
                    case "div":
                        template = { prototype: Object.create(HTMLDivElement.prototype) }
                        break;
                    case "span":
                        template = { prototype: Object.create(HTMLSpanElement.prototype) }
                        break;
                    case "a":
                        template = { prototype: Object.create(HTMLAnchorElement.prototype) }
                        break;
                }
            }
            document.registerElement(this.elTable[el], template);
        }
    }

    // "private" method
    _fromTEI(TEI_dom) {        
        let root_el = TEI_dom.documentElement;
        let els = Array.from(root_el.getElementsByTagName("*"));
        els.unshift(root_el); // Add the root element to the array
        // TODO: this may need some safeguards for large files (a promise?)
        for (let el of els) {
            this.elTable[el.tagName] = "tei-" + el.tagName;
        }
    }

}

// Make main class available to pre-ES6 browser environments 
if (window) {
    window.TEIditto = TEIditto;
}
export default TEIditto;