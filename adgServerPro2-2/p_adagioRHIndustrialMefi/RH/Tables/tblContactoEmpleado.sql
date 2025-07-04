USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [RH].[tblContactoEmpleado](
	[IDContactoEmpleado] [int] IDENTITY(1,1) NOT NULL,
	[IDEmpleado] [int] NOT NULL,
	[IDTipoContactoEmpleado] [int] NOT NULL,
	[Value] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Predeterminado] [bit] NULL,
 CONSTRAINT [PK_RHtblContactoEmpleado_IDContactoEmpleado] PRIMARY KEY CLUSTERED 
(
	[IDContactoEmpleado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RHtblContactoEmpleado_IDEmpleado] ON [RH].[tblContactoEmpleado]
(
	[IDEmpleado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RHtblContactoEmpleado_IDTipoContactoEmpleado] ON [RH].[tblContactoEmpleado]
(
	[IDTipoContactoEmpleado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [RH].[tblContactoEmpleado] ADD  CONSTRAINT [D_RHTblContactoEmpleado_Predeterminado]  DEFAULT ((0)) FOR [Predeterminado]
GO
ALTER TABLE [RH].[tblContactoEmpleado]  WITH CHECK ADD  CONSTRAINT [FK_RHtblCatTipoContactoEmpleado_RHtblContactoEmpleado_IDTipoContacto] FOREIGN KEY([IDTipoContactoEmpleado])
REFERENCES [RH].[tblCatTipoContactoEmpleado] ([IDTipoContacto])
GO
ALTER TABLE [RH].[tblContactoEmpleado] CHECK CONSTRAINT [FK_RHtblCatTipoContactoEmpleado_RHtblContactoEmpleado_IDTipoContacto]
GO
ALTER TABLE [RH].[tblContactoEmpleado]  WITH CHECK ADD  CONSTRAINT [FK_RHTblEmpleados_RHtblContactoEmpleado_IDEmpleado] FOREIGN KEY([IDEmpleado])
REFERENCES [RH].[tblEmpleados] ([IDEmpleado])
GO
ALTER TABLE [RH].[tblContactoEmpleado] CHECK CONSTRAINT [FK_RHTblEmpleados_RHtblContactoEmpleado_IDEmpleado]
GO
