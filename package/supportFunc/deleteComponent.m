function deleteComponent(Component)

go(Component, Component.Children)

function go(Component, Children)
    if ~isfield(Component, 'Children')
        delete(Component)
    elseif isempty(Children)
        delete(Component)
    else
        for child = Component.Children
            go(child, child.Children)
        end
        delete(Component)
    end
end

end