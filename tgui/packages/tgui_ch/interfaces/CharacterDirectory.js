import { Fragment } from 'inferno';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, Icon, LabeledList, Section, Table } from '../components';
import { Window } from '../layouts';

const getTagColor = (tag) => {
  switch (tag) {
    case 'Unset':
      return 'label';
    case 'Pred':
      return 'red';
    case 'Pred-Pref':
      return 'orange';
    case 'Prey':
      return 'blue';
    case 'Prey-Pref':
      return 'green';
    case 'Switch':
      return 'yellow';
    case 'Non-Vore':
      return 'black';
  }
};

export const CharacterDirectory = (props, context) => {
  const { act, data } = useBackend(context);

  const {
    personalVisibility,
    personalTag,
    personalGenderTag,
    personalSexualityTag,
    personalErpTag,
    personalEventTag,
  } = data;

  const [overlay, setOverlay] = useLocalState(context, 'overlay', null);

  const [overwritePrefs, setOverwritePrefs] = useLocalState(
    context,
    'overwritePrefs',
    false
  );

  return (
    <Window width={816} height={722} resizeable>
      <Window.Content scrollable>
        {(overlay && <ViewCharacter />) || (
          <Fragment>
            <Section
              title="Settings and Preferences"
              buttons={
                <Fragment>
                  <Box color="label" inline>
                    Save to current preferences slot:&nbsp;
                  </Box>
                  <Button
                    icon={overwritePrefs ? 'toggle-on' : 'toggle-off'}
                    selected={overwritePrefs}
                    content={overwritePrefs ? 'On' : 'Off'}
                    onClick={() => setOverwritePrefs(!overwritePrefs)}
                  />
                </Fragment>
              }>
              <LabeledList>
                <LabeledList.Item label="Visibility">
                  <Button
                    fluid
                    content={personalVisibility ? 'Shown' : 'Not Shown'}
                    onClick={() =>
                      act('setVisible', { overwrite_prefs: overwritePrefs })
                    }
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Vore Tag">
                  <Button
                    fluid
                    content={personalTag}
                    onClick={() =>
                      act('setTag', { overwrite_prefs: overwritePrefs })
                    }
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Gender">
                  <Button
                    fluid
                    content={personalGenderTag}
                    onClick={() =>
                      act('setGenderTag', { overwrite_prefs: overwritePrefs })
                    }
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Sexuality">
                  <Button
                    fluid
                    content={personalSexualityTag}
                    onClick={() =>
                      act('setSexualityTag', {
                        overwrite_prefs: overwritePrefs,
                      })
                    }
                  />
                </LabeledList.Item>
                <LabeledList.Item label="ERP Tag">
                  <Button
                    fluid
                    content={personalErpTag}
                    onClick={() =>
                      act('setErpTag', { overwrite_prefs: overwritePrefs })
                    }
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Event Pref">
                  <Button
                    fluid
                    content={personalEventTag}
                    onClick={() =>
                      act('setEventTag', { overwrite_prefs: overwritePrefs })
                    }
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Advertisement">
                  <Button
                    fluid
                    content="Edit Ad"
                    onClick={() =>
                      act('editAd', { overwrite_prefs: overwritePrefs })
                    }
                  />
                </LabeledList.Item>
              </LabeledList>
            </Section>
            <CharacterDirectoryList />
          </Fragment>
        )}
      </Window.Content>
    </Window>
  );
};

const ViewCharacter = (props, context) => {
  const [overlay, setOverlay] = useLocalState(context, 'overlay', null);

  return (
    <Section
      title={overlay.name}
      buttons={
        <Button
          icon="arrow-left"
          content="Back"
          onClick={() => setOverlay(null)}
        />
      }>
      <Section level={2} title="Species">
        <Box>{overlay.species}</Box>
      </Section>
      <Section level={2} title="Vore Tag">
        <Box p={1} backgroundColor={getTagColor(overlay.tag)}>
          {overlay.tag}
        </Box>
      </Section>
      <Section level={2} title="Gender">
        <Box>{overlay.gendertag}</Box>
      </Section>
      <Section level={2} title="Sexuality">
        <Box>{overlay.sexualitytag}</Box>
      </Section>
      <Section level={2} title="ERP Tag">
        <Box>{overlay.erptag}</Box>
      </Section>
      <Section level={2} title="Event Pref">
        <Box>{overlay.eventtag}</Box>
      </Section>
      <Section level={2} title="Character Ad">
        <Box style={{ 'word-break': 'break-all' }} preserveWhitespace>
          {overlay.character_ad || 'Unset.'}
        </Box>
      </Section>
      <Section level={2} title="OOC Notes">
        <Box style={{ 'word-break': 'break-all' }} preserveWhitespace>
          {overlay.ooc_notes || 'Unset.'}
        </Box>
      </Section>
      <Section level={2} title="Flavor Text">
        <Box style={{ 'word-break': 'break-all' }} preserveWhitespace>
          {overlay.flavor_text || 'Unset.'}
        </Box>
      </Section>
    </Section>
  );
};

const CharacterDirectoryList = (props, context) => {
  const { act, data } = useBackend(context);

  const { directory } = data;

  const [sortId, _setSortId] = useLocalState(context, 'sortId', 'name');
  const [sortOrder, _setSortOrder] = useLocalState(
    context,
    'sortOrder',
    'name'
  );
  const [overlay, setOverlay] = useLocalState(context, 'overlay', null);

  return (
    <Section
      title="Directory"
      buttons={
        <Button icon="sync" content="Refresh" onClick={() => act('refresh')} />
      }>
      <Table>
        <Table.Row bold>
          <SortButton id="name">Name</SortButton>
          <SortButton id="species">Species</SortButton>
          <SortButton id="tag">Vore Tag</SortButton>
          <SortButton id="gendertag">Gender</SortButton>
          <SortButton id="sexualitytag">Sexuality</SortButton>
          <SortButton id="erptag">ERP Tag</SortButton>
          <SortButton id="eventtag">Event Pref</SortButton>
          <Table.Cell collapsing textAlign="right">
            View
          </Table.Cell>
        </Table.Row>
        {directory
          .sort((a, b) => {
            const i = sortOrder ? 1 : -1;
            return a[sortId].localeCompare(b[sortId]) * i;
          })
          .map((character, i) => (
            <Table.Row key={i} backgroundColor={getTagColor(character.tag)}>
              <Table.Cell p={1}>{character.name}</Table.Cell>
              <Table.Cell>{character.species}</Table.Cell>
              <Table.Cell>{character.tag}</Table.Cell>
              <Table.Cell>{character.gendertag}</Table.Cell>
              <Table.Cell>{character.sexualitytag}</Table.Cell>
              <Table.Cell>{character.erptag}</Table.Cell>
              <Table.Cell>{character.eventtag}</Table.Cell>
              <Table.Cell collapsing textAlign="right">
                <Button
                  onClick={() => setOverlay(character)}
                  color="transparent"
                  icon="sticky-note"
                  mr={1}
                  content="View"
                />
              </Table.Cell>
            </Table.Row>
          ))}
      </Table>
    </Section>
  );
};

const SortButton = (props, context) => {
  const { act, data } = useBackend(context);

  const { id, children } = props;

  // Hey, same keys mean same data~
  const [sortId, setSortId] = useLocalState(context, 'sortId', 'name');
  const [sortOrder, setSortOrder] = useLocalState(context, 'sortOrder', 'name');

  return (
    <Table.Cell collapsing>
      <Button
        width="100%"
        color={sortId !== id && 'transparent'}
        onClick={() => {
          if (sortId === id) {
            setSortOrder(!sortOrder);
          } else {
            setSortId(id);
            setSortOrder(true);
          }
        }}>
        {children}
        {sortId === id && (
          <Icon name={sortOrder ? 'sort-up' : 'sort-down'} ml="0.25rem;" />
        )}
      </Button>
    </Table.Cell>
  );
};
