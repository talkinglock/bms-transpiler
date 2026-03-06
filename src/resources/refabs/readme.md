
Refabs are designed to be drop in multi-class replacements for single class XenEngine components which don't have a direct subsitute in Source.

## TERMINOLOGY ##

For brevity, classes in Black Mesa/XenEngine that are not present in Source are referred to as Xen Classes.

A "direct" Xen Class means there is a direct replacement with only one class. For example, the new lights used in XenEngine 
can simply be replaced with a light entity of similar properties.

A "fabbed" (fabricated) Xen Class means there is not a direct replacement with only one class. For example, the tripmines first
seen in "We've got hostiles!" do not have a single class replacement.

## REFABS ##

As previously mentioned, a refab is simply a collection of entities acting as if it were a single entity.
For example, the explosive tripmine could be replaced with a trigger, a model, and an explosion entity.
Inside the metadata for the tripmine would be its connection replacements, the transpiler at translation time will automatically substitute
all connections.

The specific syntax for all of this isn't yet developed, as of writing this the Refab system is theoretical.

