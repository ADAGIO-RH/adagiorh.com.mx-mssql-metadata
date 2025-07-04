USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--use d_adagioRH_1_5;
--go
CREATE proc [Reportes].[spInterfazTASY] as
	declare @tempCatEstadosCiviles as table(
		IDEstadoCivil	int,
		Codigo	varchar(10),
		Descripcion	varchar(20),
		IDEstadoCivilTASY int,
		DescripcionTASY varchar(50)
	)

	insert @tempCatEstadosCiviles(IDEstadoCivil, Codigo, Descripcion, IDEstadoCivilTASY, DescripcionTASY)
	values
		 (1,	1,	'SOLTERO (A)',		1, 'Soltero')
		,(2,	2,	'CASADO (A)',		2, 'Casado')
		,(5,	5,	'DIVORCIADO (A)',	3, 'Divorciado')
		,(90,	90,	'Soltero',			4, 'Desquitado')
		,(4,	4,	'VIUDO (A)',		5, 'Viudo')
		,(91,	91,	'Soltero',			9, 'Otros')
		,(92,	92,	'Soltero',			6, 'Separado')
		,(3,	3,	'UNION LIBRE',		7, 'Concubinato/Unión Libre')

	begin -- paises
		print 0
		--1 Brasil
		--32 Cingapura
		--43 Egito
		--55 Escócia
		--61 Dinamarca
		--103 Rússia
		--107 Sérvia
		--130 Afeganistão
		--131 África do Sul
		--132 Albânia
		--133 Alemanha
		--134 Andorra
		--135 Angola
		--136 Anguilla
		--137 Antárctica
		--138 Antiga e Barbuda
		--139 Antilhas Holandesas
		--140 Arábia Saudita
		--141 Argélia
		--142 Argentina
		--143 Armênia
		--144 Aruba
		--145 Austrália
		--146 Áustria
		--147 Azerbaidjão
		--148 Bahamas
		--149 Bangladesh
		--150 Barbados
		--151 Bareine
		--152 Belarus
		--153 Bélgica
		--154 Belize
		--155 Benin
		--156 Bermuda
		--157 Bolívia
		--158 Bósnia-Herzegóvina
		--159 Botswana
		--161 Brunei Darussalam
		--162 Bulgária
		--163 Burkina Faso
		--164 Burundi
		--165 Butão
		--166 Cabo Verde
		--167 Camarões
		--168 Camboja
		--169 Canadá
		--170 Catar
		--171 Cazaquistão
		--172 Chade
		--173 Chile
		--174 China
		--175 Chipre
		--176 Cingapura
		--177 Colômbia
		--178 Comores
		--179 Congo
		--180 Coréia do Norte
		--181 Coréia do Sul
		--182 Costa do Marfim
		--183 Costa Rica
		--184 Croácia
		--185 Cuba
		--187 Djibuti
		--188 Dominica
		--190 El Salvador
		--191 Emirados Árabes Unidos
		--192 Equador
		--193 Eritréia
		--194 Eslováquia
		--195 Eslovênia
		--196 Espanha
		--197 Estados Unidos da América
		--198 Estônia
		--199 Etiópia
		--200 Federação Russa
		--201 Fiji
		--202 Filipinas
		--203 Finlândia
		--204 França
		--205 França Metropolitana
		--206 Gabão
		--207 Gâmbia
		--208 Gana
		--209 Geórgia
		--210 Gibraltar
		--211 Grã-Bretanha
		--212 Granada
		--213 Grécia
		--214 Groenlândia
		--215 Guadalupe
		--216 Guam
		--217 Guatemala
		--218 Guiana
		--219 Guiana Francesa
		--220 Guiné
		--221 Guiné Equatorial
		--222 Guiné-Bissau
		--223 Haiti
		--224 Holanda
		--225 Honduras
		--226 Hong Kong
		--227 Hungria
		--228 Iêmen
		--229 Ilha Bouvet
		--230 Ilha Christmas
		--231 Ilha Norfolk
		--232 Ilhas Cayman
		--233 Ilhas Cocos
		--234 Ilhas Cook
		--235 Ilhas de Guernsey
		--236 Ilhas de Jersey
		--237 Ilhas Faroe
		--238 Ilhas Geórgia do Sul e Ilhas S
		--239 Ilhas Heard e Mac Donald
		--240 Ilhas Malvinas
		--241 Ilhas Mariana
		--242 Ilhas Marshall
		--243 Ilhas Pitcairn
		--244 Ilhas Reunião
		--245 Ilhas Salomão
		--246 Ilhas Santa Helena
		--247 Ilhas Svalbard e Jan Mayen
		--248 Ilhas Tokelau
		--249 Ilhas Turks e Caicos
		--250 Ilhas Virgens
		--251 Ilhas Virgens Britânicas
		--252 Ilhas Wallis e Futuna
		--253 Índia
		--254 Indonésia
		--255 Irã
		--256 Iraque
		--257 Irlanda
		--258 Islândia
		--259 Israel
		--260 Itália
		--261 Iugoslávia
		--262 Jamaica
		--263 Japão
		--264 Jordânia
		--265 Kiribati
		--266 Kuweit
		--267 Laos
		--268 Lesoto
		--269 Letônia
		--270 Líbano
		--271 Libéria
		--272 Líbia
		--273 Liechtenstein
		--274 Lituânia
		--275 Luxemburgo
		--276 Macau
		--277 Macedônia
		--278 Madagascar
		--279 Malásia
		--280 Malawi
		--281 Maldivas
		--282 Mali
		--283 Malta
		--284 Marrocos
		--285 Martinica
		--286 Maurício
		--287 Mauritânia
		--288 Mayotte
		--289 México
		--290 Mianmar
		--291 Micronésia
		--292 Moçambique
		--293 Moldávia
		--294 Mônaco
		--295 Mongólia
		--296 Montserrat
		--297 Namíbia
		--298 Nauru
		--299 Nepal
		--300 Nicarágua
		--301 Niger
		--302 Nigéria
		--303 Niue
		--304 Noruega
		--305 Nova Caledônia
		--306 Nova Zelândia
		--307 Omã
		--308 Palau
		--309 Panamá
		--310 Papua Nova Guiné
		--311 Paquistão
		--312 Paraguai
		--313 Peru
		--314 Polinésia Francesa
		--315 Polônia
		--316 Porto Rico
		--317 Portugal
		--318 Quênia
		--319 Quirguízia
		--320 República Centro-Africana
		--321 República Dominicana
		--322 República Tcheca
		--323 Romênia
		--324 Ruanda
		--325 Sahara Ocidental
		--326 Samoa Americana
		--327 Samoa Ocidental
		--328 San Marino
		--329 Santa Lúcia
		--330 São Cristóvão e Névis
		--331 São Pierre e Miquelon
		--332 São Tomé e Príncipe
		--333 São Vicente e Granadinas
		--334 Seicheles
		--335 Senegal
		--336 Serra Leoa
		--337 Síria
		--338 Somália
		--339 Sri Lanka
		--340 Suazilândia
		--341 Sudão
		--342 Suécia
		--343 Suíça
		--344 Suriname
		--345 Tadjiquistão
		--346 Tailândia
		--347 Taiwan
		--348 Tanzânia
		--349 Territórios Franceses Meridion
		--350 Timor Leste
		--351 Togo
		--352 Tonga
		--353 Trinidad e Tobago
		--354 Tunísia
		--355 Turcomênia
		--356 Turquia
		--357 Tuvalu
		--358 Ucrânia
		--359 Uganda
		--360 Uruguai
		--361 Uzbequistão
		--362 Vanuatu
		--363 Vaticano
		--364 Venezuela
		--365 Vietnã
		--366 Zâmbia
		--367 Zimbábue
		--368 Brunei
		--369 Estado da Palestina
		--370 Guiné Equatorial
		--371 Ilhas Guernsey
		--372 Japão
		--373 Jersey
		--374 Montenegro
		--375 Sérvia
	end
	select
		(
			select 
				22 as ID_EVENT,
				1 as ID_APPLICATION
			FOR XML PATH(''), TYPE
		),
		(
			select top 30			 
				'INSERT'				as IE_ACTION,
				''						as CD_NATURAL_PERSON,
				persons.CURP			as CD_CURP,
				''						as CD_NACIONALITY,
				persons.RFC				as CD_RFC,
				persons.ClaveEmpleado	as CD_OLD_SYSTEM,
				FORMAT(persons.FechaNacimiento, 'yyyyMMdd') as DT_BIRTH,
				estadosCiviles.IDEstadoCivilTASY			as IE_MARTIAL_STATUS,
				'S'											as IE_EMPLOYEE,
				SUBSTRING(persons.Sexo, 1,1)				as IE_GENDER,
				'3' IE_PERSON_TYPE,
				persons.Nombre NM_FIRST_NAME,
				persons.Paterno NM_MOTHER_LAST_NAME,
				persons.Materno NM_FATHER_LAST_NAME,
				null NR_MEDICAL_RECORD,
				'55' NR_CELL_PHONE_COUNTRY_CODE,
				'' NR_CELL_PHONE,
				null IE_RELATIVES_TYPE,
				null CD_HOLDER,
				'' DT_UPDATE,
				'' NM_USER,
				'1' CD_ESTABLISHMENT,
				(select 
					'INSERT' as IE_ACTION,
					adress.CodigoPostal as CD_ZIP_CODE,
					adress.Colonia as DS_NEIGHBORHOOD,
					adress.Calle as DS_COMPLEMENT,
					adress.Direccion as DS_ADDRESS,
					adress.Municipio as DS_MUNICIPALITY	,
					'1' as IE_COMPLEMENT_TYPE,
					adress.Exterior as NR_ADDRESS,
					adress.IDPais as NR_COUNTRY,
					adress.CodigoEstado as SG_STATE ,
					'admin' as NM_USER ,
					'' as DT_UPDATE			
				from RH.tblEmpleadosMaster compements with (nolock) 
					left join (	
						Select 
							DE.IDEmpleado,
							isnull(p.IDPais,0) as IDPais,
							E.Codigo as CodigoEstado,
							isnull(E.NombreEstado,DE.Estado) as Estado,
							isnull(DE.IDMunicipio,0) as IDMunicipio,
							isnull(M.Descripcion,DE.Municipio) as Municipio,
							isnull(DE.IDColonia,0) as IDColonia,
							isnull(C.NombreAsentamiento,DE.Colonia) as Colonia,
							isnull(DE.IDLocalidad,0) as IDLocalidad,
							isnull(L.Descripcion,DE.Localidad) as Localidad,
							isnull(DE.IDCodigoPostal,0) as IDCodigoPostal,
							isnull(CP.CodigoPostal,DE.CodigoPostal) as CodigoPostal,
							DE.Calle,
							DE.Exterior,
							DE.Interior,
							case when P.Descripcion			is not null  then coalesce(P.Descripcion,'') + ', ' else '' end
								+ case when (e.NombreEstado is not null or de.Estado is not null) then  isnull(E.NombreEstado,coalesce(DE.Estado,''))+ ', ' else '' end
								+ case when (M.Descripcion	is not null or de.Municipio is not null) then  isnull(M.Descripcion,coalesce(DE.Municipio,''))+ ', ' else '' end
								+ case when (C.NombreAsentamiento	is not null or de.Colonia is not null) then  isnull(C.NombreAsentamiento,coalesce(DE.Colonia,''))+ ', ' else '' end
								+ case when (L.Descripcion			is not null or de.Localidad is not null) then  isnull(L.Descripcion,coalesce(DE.Localidad,''))+ ', ' else '' end
								+ case when (CP.CodigoPostal		is not null or de.CodigoPostal is not null) then  isnull(CP.CodigoPostal,coalesce(DE.CodigoPostal,''))+ ', ' else '' end
								+ case when DE.Calle		is not null then DE.Calle+' ' else '' end 
								+ case when DE.Exterior		is not null then DE.Exterior +' - ' else '' end
								+ coalesce(DE.Interior,'') as Direccion,			   			   
							   --isnull(E.NombreEstado,'NINGUNO')+', '+
							   -- isnull(M.Descripcion,'NINGUNO')+', '+
							   -- isnull(C.NombreAsentamiento,'NINGUNO')+', CP:'+isnull(cp.CodigoPostal,'')+', Calle '+
							isnull(DE.IDRuta,0) as IDRuta,
							JSON_VALUE(RT.Traduccion, FORMATMESSAGE('$.%s.%s', +lower(replace('esmx', '-','')), 'Descripcion')) as Ruta
						From RH.tblDireccionEmpleado DE with (nolock)
							Left join Sat.tblCatCodigosPostales CP with (nolock) on CP.IDCodigoPostal = DE.IDCodigoPostal
							Left join Sat.tblCatEstados			E  with (nolock) on DE.IDEstado = E.IDEstado
							Left join Sat.tblCatMunicipios		M  with (nolock) on DE.IDMunicipio = M.IDMunicipio
							Left join Sat.tblCatColonias		C  with (nolock) on DE.IDColonia = C.IDColonia
							Left join Sat.tblCatPaises			p  with (nolock) on DE.IDPais = p.IDPais
							Left join Sat.tblCatLocalidades		L  with (nolock) on DE.IDLocalidad = L.IDLocalidad
							Left Join RH.tblCatRutasTransporte RT  with (nolock) on RT.IDRuta = DE.IDRuta
					) adress on adress.IDEmpleado = compements.IDEmpleado
				where compements.IDEmpleado = persons.IDEmpleado
				for XML PATH('COMPLEMENT'), type) as COMPLEMENTS
			from RH.tblEmpleadosMaster persons with (nolock)
				left join @tempCatEstadosCiviles estadosCiviles on estadosCiviles.IDEstadoCivil = persons.IDEstadoCiviL
			where ClaveEmpleado = 'ADG0003'
			order by ClaveEmpleado
			FOR XML PATH ('NATURAL_PERSON'), type--, root('STRUCTURE') , ELEMENTS XSINIL 
		)
	FOR XML RAW (''), ROOT ('STRUCTURE'), ELEMENTS XSINIL;
/*

declare @t table (col1 varchar(10), col2 varchar(10), det1 varchar(100), det2 varchar(100))

insert into @t values ('Header1', 'HeadInfo', 'DetailC1_1', 'DetailC2_1')
insert into @t values ('Header1', 'HeadInfo', 'DetailC1_2', 'DetailC2_2')

select 
	col1, col2, 
	(select 
		det1 as [Detail1], 
		det2 as [Detail2] 
	from @t T2 
	where T2.col1 = T.col1

for XML PATH('Details'), type) as Details

from @t T 
group by col1, col2
FOR XML PATH('Header'),root('root') , ELEMENTS XSINIL 

*/


--select *
--from RH.tblCatEstadosCiviles
GO
