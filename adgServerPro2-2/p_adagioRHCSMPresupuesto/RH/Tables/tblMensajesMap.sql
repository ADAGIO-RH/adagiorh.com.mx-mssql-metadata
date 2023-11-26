USE [p_adagioRHCSMPresupuesto]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [RH].[tblMensajesMap](
	[MensajeTipo] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[IDMensajeTipo] [int] NOT NULL,
	[Mensaje] [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Valid] [bit] NOT NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [uq_tblMensajesMap_MensajeTipo_IDMensajeTipo] ON [RH].[tblMensajesMap]
(
	[MensajeTipo] ASC,
	[IDMensajeTipo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [RH].[tblMensajesMap] ADD  DEFAULT ((0)) FOR [Valid]
GO
