USE [q_adagioRHTuning]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [Seguridad].[spBuscarAllUsuarios] 
as
select IDUsuario, LOWER(cuenta) cuenta, FORMAT(e.FechaNacimiento, 'ddMMyyyy') as FechaNacimiento, Activo
from RH.tblEmpleadosMaster e  
 left join Seguridad.tblUsuarios u on e.IDEmpleado = u.IDEmpleado   
where Cuenta in (
'RD01229',
'RD01033',
'CU01159',
'RD01028',
'SL01216',
'RD01082',
'SL00872',
'CU01170',
'RD01060',
'RD00996',
'RD01061',
'RD00986',
'RD01112',
'SL00869',
'CU01161',
'CU01184',
'SL00865',
'RD01026',
'RD01244',
'SL00867',
'CU01172',
'CU01211',
'DE01151',
'RD01021',
'SM01274',
'SL00862',
'RD01011',
'RD01238',
'CU01182',
'CU01158',
'CU01192',
'RD01006',
'CU01204',
'RD01232',
'RD01097',
'SM01275',
'RD01027',
'RD01044',
'RD01052',
'CU01198',
'RD01000',
'RD01086',
'RD01058',
'CU01171',
'RD01030',
'RD00988',
'RD00991',
'RD01224',
'SL00856',
'RD01034',
'RD01234',
'RD01001',
'RD01051',
'CU01208',
'RD01237',
'RD01038',
'SL00864',
'RD01054',
'RD01231',
'RD01227',
'RD01083',
'RD01073',
'RD01233',
'RD01107',
'RD01079',
'SL00868',
'RD01029',
'CU01169',
'CU01203',
'SL00860',
'RD00964',
'SL00857',
'RD00969',
'CU01201',
'CU01193',
'RD00983',
'RD00980',
'RD01055',
'CU01155',
'CU01176',
'RD01235',
'CU01180',
'RD01076',
'RD00975',
'CU01186',
'RD01067',
'RD01043',
'CU01185',
'CU01209',
'CU01168',
'RD01078',
'RD00976',
'CU01199',
'CU01202',
'CU01188',
'RD00965',
'RD01064',
'CU01206',
'SL00861',
'RD01106',
'RD01092',
'RD01252',
'RD00982',
'CU01187',
'RD01070',
'RD00977',
'SM01273',
'RD01045',
'CU01194',
'RD01041',
'CU01190',
'RD01230',
'CU01196',
'CU01179',
'SL00870',
'CU01163',
'RD01077',
'RD01066',
'RD00994',
'CU01177',
'RD01007',
'RD01089',
'RD01108',
'SL00871',
'NA01268',
'CU01154',
'CU01254',
'RD01090',
'RD00981',
'RD01068',
'CU01173',
'RD01228',
'RD01085',
'CU01153',
'RD01012',
'RD00968',
'RD00970',
'SL00858',
'CU01256',
'RD01096',
'RD01080',
'RD01062',
'RD01023',
'RD01099',
'RD01276',
'RD00987',
'RD01104',
'CU01162',
'CU01167',
'RD01069',
'RD01110',
'RD00999',
'RD01039',
'RD01047',
'RD01091',
'CU01164',
'RD01102',
'RD01101',
'RD00992',
'RD01002',
'RD01226',
'CU01191',
'RD01015',
'RD01016',
'RD01024',
'SL00899',
'RD01225',
'CU01178',
'RD01059',
'DE01152',
'RD01074',
'RD01253',
'RD01057',
'RD01243',
'RD01017',
'CU01157',
'SL00866',
'RD01103',
'RD01246',
'RD01277',
'CU01189',
'CU01205',
'RD01241',
'RD01094',
'RD01003',
'RD01063',
'RD01025',
'RD01036',
'RD01053',
'RD00971',
'RD01009',
'RD01240',
'RD01223',
'RD01247',
'RD00978',
'SL00859',
'RD01095',
'RD00993',
'RD01109',
'RD00967',
'RD01261',
'RD01018',
'RD01019',
'RD01004',
'RD00989',
'SL01217',
'RD01111',
'CU01207',
'CU01255',
'CU01181',
'CU01166',
'RD01048',
'CU01183',
'RD00972',
'RD01056',
'ON01269',
'CU01165',
'SL00873',
'SL00951',
'RD00973',
'RD01239',
'SL00863',
'RD01005',
'RD00995',
'CU01267',
'RD01084',
'RD01257',
'CU01266',
'CU01160',
'CU01174',
'RD01010',
'AN00846',
'CU01263',
'RD01081',
'CU01156',
'RD01075',
'RD01098',
'RD01020',
'RD01218',
'RD01037',
'RD00985',
'RD01236',
'CU01175',
'RD01035',
'RD01042',
'RD01050',
'SM01272',
'RD01049',
'CU01197',
'CU01210',
'CU01265'
)
--where isnull(u.Activo,0) = 0
order by Cuenta
GO
